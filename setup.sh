#!/usr/bin/env bash
# ============================================================================
# setup.sh — Install every dependency needed by this AstroNvim config
#
# Supports: macOS (Homebrew), Linux (Debian/Ubuntu, Arch, Fedora, Alpine)
#           and iSH on iPad (Alpine/i386)
# Usage:    bash setup.sh   (idempotent — safe to re-run any number of times)
#
# Installs:
#   • Neovim >= 0.11          (official tarball on Debian/Ubuntu/old Fedora)
#   • Maple Mono NF Nerd Font (skipped on iSH — the iOS app renders fonts)
#   • Node.js LTS via nvm     (Alpine/iSH use apk: official Node builds are glibc-only)
#   • git, curl, wget, unzip, ripgrep, fd, lazygit, shellcheck, shfmt
#   • C toolchain (Treesitter parser compilation) + python3 (Mason/debugpy)
#   • Backs up ~/.config/nvim (if any) and symlinks this repo into place
# ============================================================================

# --- Bootstrap: the script needs bash. On Alpine/iSH it may run under ash ---
if [ -z "${BASH_VERSION:-}" ]; then
  echo "[setup] bash is required, trying to install it..."
  if ! command -v bash >/dev/null 2>&1 && command -v apk >/dev/null 2>&1; then
    apk add --no-cache bash curl ca-certificates 2>/dev/null \
      || doas apk add --no-cache bash curl ca-certificates 2>/dev/null \
      || sudo apk add --no-cache bash curl ca-certificates 2>/dev/null \
      || true
  fi
  command -v bash >/dev/null 2>&1 || {
    echo "Error: bash not found. Install it manually and re-run: apk add bash curl" >&2
    exit 1
  }
  exec bash "$0" "$@"
fi

set -euo pipefail

# ---------------------------------------------------------------- helpers ---
info() { printf '\033[1;34m[setup]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[  ok  ]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn ]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[FAIL ]\033[0m %s\n' "$*" >&2; exit 1; }
trap 'warn "Failed at line $LINENO — see output above"' ERR

# Append $1 to .bashrc/.zshrc when not present yet (checked via substring $2)
append_rc() {
  local line="$1" marker="$2" rc
  [ -f "$HOME/.bashrc" ] || [ -f "$HOME/.zshrc" ] || touch "$HOME/.bashrc"
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] || continue
    grep -qF "$marker" "$rc" 2>/dev/null || printf '%s\n' "$line" >> "$rc"
  done
}

ensure_local_bin_on_path() {
  case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
  append_rc 'export PATH="$HOME/.local/bin:$PATH"' '.local/bin'
}

# version_ge <current> <minimum> → exit 0 when current >= minimum
version_ge() {
  [ "$2" = "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" ]
}

# --------------------------------------------------------------- detection ---
PLATFORM="$(uname -s)"
case "$PLATFORM" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *) die "Unsupported OS: $PLATFORM (supported: macOS, Linux, iSH)" ;;
esac

ARCH="$(uname -m)"
DISTRO=""
IS_ISH=false
if [ "$PLATFORM" = "linux" ]; then
  if [ -f /etc/os-release ]; then . /etc/os-release; DISTRO="${ID:-}"; fi
  # Map derived distros (Mint, Pop!_OS, Manjaro, ...) onto their parent branch via ID_LIKE
  case "${ID_LIKE:-}" in
    *debian* | *ubuntu*) case "$DISTRO" in debian | ubuntu) ;; *) DISTRO="ubuntu" ;; esac ;;
    *arch*)    DISTRO="arch" ;;
    *fedora* | *rhel*) DISTRO="fedora" ;;
    *alpine*)  DISTRO="alpine" ;;
  esac
  # iSH kernel versions carry an "-ish" suffix, e.g. "5.15.0-ish"
  if uname -r | grep -qi -- '-ish'; then IS_ISH=true; fi
fi

SUDO=""
if [ "$PLATFORM" = "linux" ] && [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then SUDO="sudo"
  elif command -v doas >/dev/null 2>&1; then SUDO="doas"
  else die "No sudo/doas available — run as root or install sudo, then retry"
  fi
fi

if [ "$IS_ISH" = true ]; then
  info "Platform: $PLATFORM${DISTRO:+ ($DISTRO)} | ARCH: $ARCH | iSH (iPad)"
else
  info "Platform: $PLATFORM${DISTRO:+ ($DISTRO)} | ARCH: $ARCH"
fi

# --------------------------------------------------------- package managers ---
pkg_install() {
  if [ "$PLATFORM" = "macos" ]; then brew install "$@"; return; fi
  case "$DISTRO" in
    ubuntu | debian) $SUDO apt-get install -y "$@" ;;
    arch)            $SUDO pacman -S --needed --noconfirm "$@" ;;
    fedora)          $SUDO dnf install -y "$@" ;;
    alpine)          $SUDO apk add "$@" ;;
    *) die "Unsupported distro: ${DISTRO:-unknown} — install manually per the README" ;;
  esac
}

# Install optional packages: warn on failure instead of aborting
try_install() {
  local pkg cmd
  for pkg in "$@"; do
    cmd="$pkg"
    if [ "$pkg" = "wl-clipboard" ]; then cmd="wl-copy"; fi # package name != binary name
    command -v "$cmd" >/dev/null 2>&1 && continue
    pkg_install "$pkg" >/dev/null 2>&1 || warn "Could not install '$pkg' — skipping (not required)"
  done
}

ensure_brew() {
  command -v brew >/dev/null 2>&1 && return
  info "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"
  fi
  command -v brew >/dev/null 2>&1 || die "Homebrew installation failed"
}

# ------------------------------------------------------------ base packages ---
install_base() {
  info "Installing base packages (git, curl, ripgrep, fd, toolchain, python3...)"
  case "$PLATFORM-$DISTRO" in
    macos-*)
      ensure_brew
      pkg_install git curl wget unzip ripgrep fd lazygit shellcheck shfmt
      ;;
    linux-ubuntu | linux-debian)
      $SUDO apt-get update -y
      pkg_install git curl wget unzip ca-certificates build-essential \
        python3 python3-pip python3-venv ripgrep fd-find fontconfig
      ;;
    linux-arch)
      pkg_install git curl wget unzip gcc make python python-pip \
        ripgrep fd fontconfig lazygit shellcheck shfmt
      ;;
    linux-fedora)
      pkg_install git curl wget unzip gcc make python3 python3-pip \
        ripgrep fd-find fontconfig
      ;;
    linux-alpine)
      pkg_install git curl wget unzip ca-certificates build-base bash tar \
        python3 py3-pip ripgrep fd fontconfig
      if [ "$IS_ISH" = true ]; then
        info "iSH: the emulated CPU is slow — some packages take a while, do not interrupt"
      fi
      ;;
    *) die "Unsupported distro: ${DISTRO:-unknown}" ;;
  esac

  # fd on Debian/Ubuntu ships the binary as fdfind → symlink it for convenience
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
  ensure_local_bin_on_path

  # lazygit (<Leader>gg): not in apt/dnf → fetch the official binary
  if ! command -v lazygit >/dev/null 2>&1; then
    case "$DISTRO" in ubuntu | debian | fedora) install_lazygit_tarball || true ;; esac
  fi
  if ! command -v lazygit >/dev/null 2>&1 && [ "$PLATFORM" = "linux" ]; then
    try_install lazygit
  fi

  # Shell linter/formatter (nvim-lint + none-ls) + clipboard — best effort
  # (skip xclip/wl-clipboard on Alpine to avoid pulling X11 libs into iSH)
  if [ "$PLATFORM" = "linux" ] && [ "$DISTRO" != "alpine" ]; then
    try_install shellcheck shfmt xclip wl-clipboard
  else
    try_install shellcheck shfmt
  fi

  # Compiler for Treesitter on macOS: Command Line Tools
  if [ "$PLATFORM" = "macos" ] && ! xcode-select -p >/dev/null 2>&1; then
    warn "Xcode Command Line Tools missing (needed to compile Treesitter parsers)"
    xcode-select --install || true
    warn "An installer dialog has opened — click Install and wait (the script keeps going)"
  fi
}

install_lazygit_tarball() {
  local ver arch_name url tmp
  ver="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)"
  [ -n "$ver" ] || { warn "Could not resolve the latest lazygit version — skipping"; return 0; }
  case "$ARCH" in
    x86_64)        arch_name="x86_64" ;;
    aarch64|arm64) arch_name="arm64" ;;
    *) warn "No lazygit binary for $ARCH — skipping"; return 0 ;;
  esac
  url="https://github.com/jesseduffield/lazygit/releases/download/${ver}/lazygit_${ver#v}_Linux_${arch_name}.tar.gz"
  mkdir -p "$HOME/.local/bin"
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/lazygit.tar.gz" "$url" || { warn "Failed to download lazygit — skipping"; rm -rf "$tmp"; return 0; }
  tar -xzf "$tmp/lazygit.tar.gz" -C "$HOME/.local/bin" lazygit || { warn "Failed to extract lazygit — skipping"; rm -rf "$tmp"; return 0; }
  rm -rf "$tmp"
  ok "lazygit ${ver} → ~/.local/bin/lazygit"
}

# ------------------------------------------------------------------ neovim ---
install_nvim_tarball() {
  local suffix tmp extracted
  case "$ARCH" in
    x86_64)        suffix="nvim-linux-x86_64" ;;
    aarch64|arm64) suffix="nvim-linux-arm64" ;;
    *) die "No Neovim tarball available for $ARCH" ;;
  esac
  tmp="$(mktemp -d)"
  info "Downloading the latest Neovim (official tarball)..."
  curl -fsSL -o "$tmp/nvim.tar.gz" "https://github.com/neovim/neovim/releases/latest/download/${suffix}.tar.gz" \
    || curl -fsSL -o "$tmp/nvim.tar.gz" "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
  mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
  rm -rf "$HOME/.local/opt/nvim" "$HOME/.local/opt/nvim-linux-x86_64" \
    "$HOME/.local/opt/nvim-linux-arm64" "$HOME/.local/opt/nvim-linux64"
  tar -xzf "$tmp/nvim.tar.gz" -C "$HOME/.local/opt"
  extracted="$(find "$HOME/.local/opt" -maxdepth 1 -type d -name 'nvim-linux*' -print -quit)"
  [ -n "$extracted" ] || die "Neovim extraction failed"
  mv "$extracted" "$HOME/.local/opt/nvim"
  ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$tmp"
}

nvim_version() { nvim --version 2>/dev/null | head -n1 | sed -n 's/^NVIM v\([0-9][0-9.]*\).*/\1/p'; }

install_nvim() {
  info "Installing Neovim (AstroNvim v6 requires >= 0.11)"
  case "$PLATFORM-$DISTRO" in
    macos-*)          pkg_install neovim ;;
    linux-arch)       pkg_install neovim ;;
    linux-ubuntu | linux-debian) install_nvim_tarball ;; # apt versions are always too old
    linux-fedora)
      $SUDO dnf install -y neovim || true
      version_ge "$(nvim_version || echo 0)" "0.11" || install_nvim_tarball
      ;;
    linux-alpine)
      pkg_install neovim
      if ! version_ge "$(nvim_version || echo 0)" "0.11"; then
        warn "Neovim in the Alpine repos ($(nvim_version || echo '?')) is < 0.11 — trying the edge community repo"
        $SUDO apk add neovim --repository="http://dl-cdn.alpinelinux.org/alpine/edge/community" \
          || warn "Could not upgrade via edge — AstroNvim v6 needs >= 0.11, consider updating iSH/Alpine"
      fi
      ;;
  esac
  ensure_local_bin_on_path
  version_ge "$(nvim_version || echo 0)" "0.11" \
    && ok "Neovim $(nvim_version)" \
    || warn "Neovim $(nvim_version || 'not found') < 0.11 — nvim may not work correctly, see README"
}

# ---------------------------------------------------------------- node/nvm ---
install_node() {
  # Alpine uses musl (and iSH is i386): official Node binaries won't run there,
  # and compiling from source on iSH is impractical → use Alpine's package.
  if [ "$DISTRO" = "alpine" ]; then
    info "Installing Node.js via apk (nvm needs glibc binaries, unavailable on Alpine/iSH)"
    pkg_install nodejs npm
    ok "Node $(node --version) — enough for Mason/vtsls/js-debug-adapter"
    return
  fi

  info "Installing Node.js LTS via nvm"
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    local nvm_ver
    nvm_ver="$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest \
      | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)"
    [ -n "$nvm_ver" ] || nvm_ver="v0.40.3" # fallback if the GitHub API is rate-limited
    info "Installing nvm $nvm_ver..."
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_ver}/install.sh" | bash
  fi
  # shellcheck disable=SC1091
  \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm alias default 'lts/*' >/dev/null
  append_rc 'export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # load nvm' 'NVM_DIR'
  ok "Node $(node --version) (nvm, LTS)"
}

# -------------------------------------------------------------------- font ---
install_font_zip() { # $1 = destination directory
  local dest="$1" tmp
  tmp="$(mktemp -d)"
  info "Downloading Maple Mono NF (Nerd Font)..."
  curl -fsSL -o "$tmp/MapleMono-NF.zip" \
    "https://github.com/subframe7536/maple-font/releases/latest/download/MapleMono-NF.zip" \
    || { warn "Could not download the font — skipping (see README for manual install)"; rm -rf "$tmp"; return 0; }
  mkdir -p "$dest"
  unzip -oq "$tmp/MapleMono-NF.zip" -d "$dest" -x "*.md" "*LICENSE*" "*OFL*"
  rm -rf "$tmp"
}

install_font() {
  if [ "$IS_ISH" = true ]; then
    warn "iSH: fonts are rendered by the iOS app — skipping font install. For proper icons,"
    warn "      install a Nerd Font in the terminal app you use to reach iSH (Termius, Blink...)"
    return
  fi
  if [ "$PLATFORM" = "macos" ]; then
    if ls "$HOME/Library/Fonts" 2>/dev/null | grep -qi maple; then
      ok "Maple Mono NF already present in ~/Library/Fonts"
    elif brew install --cask font-maple-mono-nf >/dev/null 2>&1; then
      ok "Maple Mono NF (brew cask) → ~/Library/Fonts"
    else
      install_font_zip "$HOME/Library/Fonts"
      ok "Maple Mono NF → ~/Library/Fonts"
    fi
  else
    if command -v fc-list >/dev/null 2>&1 && fc-list | grep -qi "maple"; then
      ok "Maple Mono NF already installed"
      return
    fi
    install_font_zip "$HOME/.local/share/fonts"
    fc-cache -f >/dev/null 2>&1 || pkg_install fontconfig
    fc-cache -f >/dev/null 2>&1 || true
    ok "Maple Mono NF → ~/.local/share/fonts"
  fi
  info "Remember to set \"Maple Mono NF\" as your terminal font (iTerm2/Ghostty/kitty...)"
}

# ------------------------------------------------------------ config symlink ---
link_config() {
  local script_dir target
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  target="$HOME/.config/nvim"
  if [ "$script_dir" = "$target" ]; then
    info "Repo is already in place: $target"
    return
  fi
  if [ -e "$target" ] || [ -L "$target" ]; then
    local bak="$target.bak.$(date +%Y%m%d%H%M%S)"
    warn "Found an existing $target → backed it up to $bak"
    mv "$target" "$bak"
    warn "If it was a different Neovim config, consider backing up these too:"
    warn "  ~/.local/share/nvim, ~/.local/state/nvim, ~/.cache/nvim"
  fi
  mkdir -p "$(dirname "$target")"
  ln -s "$script_dir" "$target"
  ok "Symlinked $target → $script_dir"
}

# ------------------------------------------------------------------- summary ---
print_summary() {
  printf '\n'
  info "================ DONE ================"
  printf '  nvim:     %s\n' "$(nvim --version 2>/dev/null | head -n1 || echo 'not found')"
  printf '  node:     %s\n' "$(node --version 2>/dev/null || echo 'not found')"
  printf '  git:      %s\n' "$(git --version 2>/dev/null || echo 'not found')"
  printf '  ripgrep:  %s\n' "$(rg --version 2>/dev/null | head -n1 || echo 'not found')"
  printf '  lazygit:  %s\n' "$(lazygit --version 2>&1 | head -n1 || echo 'not found')"
  printf '\n'
  info "Next steps:"
  echo   "  1. Open a NEW terminal window (so nvm/PATH take effect)"
  echo   "  2. Set your terminal font to \"Maple Mono NF\""
  echo   "  3. Run nvim — the first launch installs plugins + LSPs via lazy.nvim/Mason (a few minutes)"
  echo   "  4. :Mason lists LSPs/formatters, <Leader>pa updates everything"
  echo   "  Note: <Leader>k (kubectl.nvim) needs the kubectl binary if you use Kubernetes"
  if [ "$IS_ISH" = true ]; then
    warn "iSH: the emulated CPU is slow — the first nvim launch will take a long while (parser compilation)."
    warn "     If Neovim < 0.11, AstroNvim v6 will not run — try the edge repo as the script suggested."
  fi
}

# --------------------------------------------------------------------- main ---
install_base
install_nvim
install_node
install_font
link_config
print_summary
