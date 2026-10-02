# NeoVim Config (AstroNvim v6)

Personal Neovim configuration based on [AstroNvim](https://astronvim.com) v6, primarily for TypeScript/Angular, Python, Go, Ansible, Terraform and DevOps tools.

- **Colorscheme:** Catppuccin Macchiato
- **Completion:** blink.cmp
- **File explorer:** neo-tree
- **Fuzzy finder:** snacks.nvim
- **LSP/formatters:** auto-installed via Mason (vtsls, angularls, basedpyright, ruff, gopls, lua_ls, yaml/helm/docker/ansible/terraform LSPs, prettierd, stylua...)
- **Font:** Maple Mono NF

## Requirements

- macOS + [Homebrew](https://brew.sh)
- Neovim **>= 0.11** (AstroNvim v6 requirement; currently running on 0.12.x)
- Git

## Installation on macOS

### 1. Install dependencies

```sh
# C compiler needed for Treesitter to compile parsers
xcode-select --install

# Neovim + ripgrep (search) + lazygit (<Leader>gg) + node (for JS/TS LSP servers)
brew install neovim ripgrep lazygit node
```

### 2. Install a Nerd Font

The font provides the icons used across the UI (so icons don't render as boxes):

```sh
brew install --cask font-maple-mono-nf
```

Then set **Maple Mono NF** as your terminal font:

| Terminal     | How to set the font                                                              |
| ------------ | -------------------------------------------------------------------------------- |
| iTerm2       | Settings → Profiles → Text → Font → `Maple Mono NF`                              |
| Ghostty      | `font-family = "Maple Mono NF"` in `~/.config/ghostty/config`                    |
| kitty        | `font_family Maple Mono NF` in `~/.config/kitty/kitty.conf`                      |
| WezTerm      | `font = wezterm.font("Maple Mono NF")` in `~/.wezterm.lua`                       |
| Alacritty    | `font.normal.family = "Maple Mono NF"` in `~/.config/alacritty.toml`             |
| Terminal.app | Settings → Profiles → Text → Change Font → `Maple Mono NF`                       |

### 3. Back up your current config (if any)

```sh
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null
mv ~/.cache/nvim ~/.cache/nvim.bak 2>/dev/null
```

### 4. Clone the config and start

```sh
git clone <this-repo-url> ~/.config/nvim
nvim
```

On first launch: lazy.nvim bootstraps plugins and Mason installs LSP servers/formatters automatically (takes a few minutes). Treesitter parsers are installed on demand when opening a new language (`auto_install = true`).

To update later: `<Leader>pa` (update Lazy + Mason) or `:Lazy sync`.

## Basic Usage

- **The leader key is `Space`**, the local leader is `,`. Press `Space` and wait a second for which-key to show a menu of all shortcuts.
- Finding things: `Space ff` (find files), `Space fw` (find words — ripgrep), `Space fb` (buffers), `Space fh` (help).
- File explorer: `Space e` toggles neo-tree, `Space o` focuses it.
- LSPs attach automatically by filetype; files are **formatted automatically on save** (prettierd/stylua/ruff...).
- Completion (blink.cmp): suggestions appear as you type — `Tab`/`S-Tab` to select, `Enter` to accept, `Esc` to dismiss.
- Floating terminal: `Ctrl+'` (or `Ctrl+/` depending on your terminal); lazygit: `Space gg`.
- Quick exits: `Space Q` (quit AstroNvim), `Space q` (close window), `Space c` (close buffer).

## Keybindings

### General

| Key         | Action                                       |
| ----------- | -------------------------------------------- |
| `Space`     | Leader — press and wait to open the menu     |
| `Space q`   | Close window                                 |
| `Space Q`   | Quit Neovim                                  |
| `Space w`   | Save file                                    |
| `Ctrl+S`    | Force write                                  |
| `Ctrl+Q`    | Force quit                                   |
| `Space n`   | New file                                     |
| `Space h`   | Home Screen (dashboard)                      |
| `Space R`   | Rename file                                  |
| `jk` / `jj` | Exit insert mode (no Esc needed)             |

### Search (`Space f`)

| Key          | Action                            |
| ------------ | --------------------------------- |
| `Space ff`   | Find files                        |
| `Space fg`   | Find files in git                 |
| `Space fw`   | Find words (grep across project)  |
| `Space fc`   | Find word under cursor            |
| `Space fb`   | Find buffers                      |
| `Space fo`   | Recently opened files             |
| `Space fl`   | Find lines                        |
| `Space fs`   | Buffers / recent / files          |
| `Space fh`   | Find help                         |
| `Space fk`   | Find keymaps                      |
| `Space ft`   | Change colorscheme                |
| `Space fT`   | Find TODOs                        |
| `Space f<CR>`| Resume previous search            |

### Buffer, Tab, Window

| Key            | Action                              |
| -------------- | ----------------------------------- |
| `]b` / `[b`    | Next / previous buffer              |
| `Space bb`     | Select buffer from tabline          |
| `Space bd`     | Close buffer (pick from tabline)    |
| `Space c`      | Close current buffer                |
| `Space bc`     | Close all buffers except current    |
| `]t` / `[t`    | Next / previous tab                 |
| `Ctrl+H/J/K/L` | Move between splits (H/J/K/L)       |
| `Ctrl+Arrows`  | Resize split                        |
| `\` / `|`      | Horizontal / vertical split         |

### LSP (enabled automatically per language)

| Key         | Action                            |
| ----------- | --------------------------------- |
| `K`         | Hover documentation               |
| `gd`        | Definition of symbol (picker)     |
| `gD`        | Declaration of symbol             |
| `gy`        | Type definition                   |
| `gI`        | Implementation                    |
| `grn`       | Rename symbol                     |
| `grr`       | References                        |
| `gra`       | Code action                       |
| `gO`        | Document symbols (outline)        |
| `gK`        | Signature help                    |
| `gl`        | Hover diagnostics                 |
| `[d` / `]d` | Previous / next diagnostic        |
| `Ctrl+W d`  | Diagnostic popup under cursor     |
| `Space lf`  | Format buffer                     |
| `Space ls`  | Search workspace symbols           |
| `Space ld`  | Search diagnostics                |
| `Space lS`  | Symbols outline (aerial)          |
| `Space li`  | LSP information                   |

### Git

| Key         | Action                          |
| ----------- | ------------------------------- |
| `Space gg`  | Open lazygit                    |
| `Space gt`  | Git status                      |
| `Space gb`  | Checkout branch                 |
| `Space gc`  | Commits log                     |
| `Space gC`  | Commits log for current file    |
| `Space go`  | Open file in browser (GitHub…)  |
| `[g` / `]g` | Previous / next hunk            |
| `[G` / `]G` | First / last hunk               |
| `Space gs`  | Stage/Unstage hunk              |
| `Space gr`  | Reset hunk                      |
| `Space gp`  | Preview hunk (inline)           |
| `Space gl`  | Git blame current line          |
| `Space gd`  | View diff                       |

### Debug (DAP)

| Key        | Action                 |
| ---------- | ---------------------- |
| `Space dc` | Start / Continue (F5)  |
| `Space db` | Toggle breakpoint (F9) |
| `Space dB` | Clear all breakpoints  |
| `Space di` | Step Into (F11)        |
| `Space do` | Step Over (F10)        |
| `Space dO` | Step Out (S-F11)       |
| `Space dp` | Pause (F6)             |
| `Space dr` | Restart                |
| `Space dq` | Close session          |
| `Space dQ` | Terminate session      |
| `Space du` | Toggle Debug UI        |
| `Space dR` | Toggle REPL            |
| `Space dh` | Debugger hover         |

### Terminal

| Key        | Action                      |
| ---------- | --------------------------- |
| `Ctrl+'`   | Toggle terminal (float)     |
| `Space tf` | Floating terminal            |
| `Space th` | Horizontal split terminal    |
| `Space tv` | Vertical split terminal      |
| `Space tl` | Terminal running lazygit     |
| `Space tn` | Terminal running node        |
| `Space tp` | Terminal running python      |

### Toggles (`Space u`)

| Key              | Action                            |
| ---------------- | --------------------------------- |
| `Space ud`       | Toggle diagnostics                |
| `Space uw`       | Toggle wrap                       |
| `Space un`       | Cycle line numbering              |
| `Space uz`       | Toggle color highlight            |
| `Space uZ`       | Zen mode                          |
| `Space uh`       | Inlay hints (buffer)              |
| `Space uf`       | Format on save (buffer)           |
| `Space ur`       | Reference highlighting            |
| `Space u(` / `u)` | Rainbow delimiters (buffer/global) |
| `Space u\|`      | Indent guides                     |

### Plugins / Mason (`Space p`)

| Key        | Action                             |
| ---------- | ---------------------------------- |
| `Space ps` | Plugins status (Lazy)              |
| `Space pi` | Install plugins                    |
| `Space pu` | Check updates                      |
| `Space pU` | Update plugins                     |
| `Space pS` | Sync plugins                       |
| `Space pm` | Mason — install LSP/formatter/DAP  |
| `Space pa` | Update both Lazy and Mason         |

### Sessions (`Space S`)

| Key        | Action                       |
| ---------- | ---------------------------- |
| `Space Ss` | Save session                 |
| `Space Sl` | Load last session            |
| `Space SS` | Save dirsession (per folder) |
| `Space S.` | Load current dirsession      |

## Config Structure

```
├── init.lua               # entry point
├── lua/
│   ├── lazy_setup.lua     # bootstrap lazy.nvim + AstroNvim
│   ├── community.lua      # import AstroCommunity packs
│   ├── polish.lua         # runs last (currently disabled)
│   └── plugins/           # per-plugin overrides
│       ├── astrocore.lua  # options, mappings, autocmds
│       ├── astrolsp.lua   # LSP servers, format_on_save
│       ├── mason.lua      # tools auto-installed via Mason
│       └── ...
└── lsp/
    └── angularls.lua      # angularls only attaches inside Angular projects
```

To add a new plugin: create a file `lua/plugins/<plugin-name>.lua`. To add/change keymaps: edit `mappings` in `lua/plugins/astrocore.lua`.
