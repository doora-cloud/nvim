# NeoVim Config (AstroNvim v6)

Personal Neovim configuration based on [AstroNvim](https://astronvim.com) v6, primarily for TypeScript/Angular, Python, Go, Ansible, Terraform and DevOps tools.

- **Colorscheme:** Catppuccin Macchiato
- **Completion:** blink.cmp
- **File explorer:** neo-tree
- **Fuzzy finder:** snacks.nvim
- **Editing:** flash.nvim (jump), mini.surround, mini.ai (textobjects), grug-far.nvim (search & replace)
- **Tests:** neotest (Vitest/Jest, pytest, go test) + DAP debugging
- **Git:** lazygit (`Space gg`), gitsigns blame, diffview.nvim (diff/file history), git-conflict.nvim (conflict highlight + `Space m` resolve keys)
- **Kubernetes:** kubectl.nvim (`Space k`) — requires the `kubectl` binary
- **Nx:** nxls LSP (autocomplete in `nx.json`/`project.json`) + nx-console.nvim (`Space N` browse & run tasks) — the LSP needs `npm i -g nxls`
- **AI assistant:** avante.nvim (`Space a` ask/edit sidebar, Cursor-style) — **only loads when `NVIM_AI_PROVIDER` is exported**; backends: z.ai / OpenAI / Cursor Agent, provider & key live in `~/.zshrc`
- **LSP/formatters:** auto-installed via Mason (vtsls, angularls, basedpyright, ruff, gopls, lua_ls, yaml/helm/docker/ansible/terraform LSPs, prettierd, stylua...)
- **Font:** Maple Mono NF

## Requirements

- macOS (Homebrew) or Linux (Debian/Ubuntu & derivatives, Arch, Fedora, Alpine — including iSH on iPad)
- Neovim **>= 0.11** (AstroNvim v6 requirement; currently running on 0.12.x)
- Git

## Quick setup (macOS / Linux / iSH)

A single command installs every dependency (Neovim, Maple Mono NF, Node LTS via nvm, git/ripgrep/fd/lazygit/shellcheck/shfmt, C toolchain, python3) and symlinks the config into `~/.config/nvim`:

```sh
bash setup.sh
```

The script is idempotent (safe to rerun as many times as you like). Platform notes:

- **Debian/Ubuntu:** Neovim is installed from the official tarball (apt is always older than 0.11); Node via nvm as required.
- **Alpine / iSH (iPad):** Node is installed via `apk` (official Node binaries are built for glibc only and won't run on iSH's musl/i386). On iSH there is no need to install a font — fonts are rendered by the iOS app; the first nvim launch will be slow because of CPU emulation.

## Manual install (macOS)

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

To update later: `<Leader>pa` (update Lazy + Mason) or `:Lazy sync`. After updating, **commit `lazy-lock.json` again** so every machine installs the exact same plugin versions, and run `:checkhealth` after major updates.

## Basic Usage

- **The leader key is `Space`**, the local leader is `,`. Press `Space` and wait a second for which-key to show a menu of all shortcuts.
- Finding things: `Space ff` (find files), `Space fw` (find words — ripgrep), `Space fb` (buffers), `Space fh` (help).
- File explorer: `Space e` toggles neo-tree, `Space o` focuses it.
- Jumping: press `s` then type any 2 visible letters to jump there instantly (flash.nvim).
- LSPs attach automatically by filetype; files are **formatted automatically on save** (prettierd/stylua/ruff...).
- Inlay hints show types/parameters (TS/JS) — temporarily turn them off with `Space uh`.
- Completion (blink.cmp): suggestions appear as you type — `Tab`/`S-Tab` to select, `Enter` to accept, `Esc` to dismiss.
- Floating terminal: `Ctrl+'` (or `Ctrl+/` depending on your terminal); lazygit: `Space gg`.
- AI assistant: `Space aa` opens the avante sidebar (needs `NVIM_AI_PROVIDER` exported — otherwise the whole plugin stays off).
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

### Search & Replace (`Space s`) — grug-far.nvim

`Space fw` only greps to *view* matches — grug-far replaces them in bulk (regex, per-file result preview, history/undo). Note the lowercase `s` — `Space S` (uppercase) is Sessions.

| Key               | Action                                    |
| ----------------- | ----------------------------------------- |
| `Space ss`        | Search/Replace across the whole workspace |
| `Space se`        | Only in files with the same filetype      |
| `Space sf`        | Only in the current file                  |
| `Space sw`        | Replace the word under the cursor         |
| `Space s` (visual)| Replace the selected region               |
| `gS` (in neo-tree)| Replace in the selected directory         |

### Buffer, Tab, Window

| Key            | Action                              |
| -------------- | ----------------------------------- |
| `]b` / `[b`    | Next / previous buffer              |
| `Space bb`     | Select buffer from tabline          |
| `Space bd`     | Close buffer (pick from tabline)    |
| `Space c`      | Close current buffer (closing the last one returns to the dashboard) |
| `Space bc`     | Close all buffers except current    |
| `]t` / `[t`    | Next / previous tab                 |
| `Ctrl+H/J/K/L` | Move between splits (H/J/K/L)       |
| `Ctrl+Arrows`  | Resize split                        |
| `\` / `|`      | Horizontal / vertical split         |

### Motion & Editing (flash, mini.surround, mini.ai)

| Key              | Action                                                       |
| ---------------- | ------------------------------------------------------------ |
| `s` + 2 letters  | **Flash jump**: jump to any location visible on screen       |
| `S`              | Flash Treesitter: select a node (press repeatedly to expand the selection, edit multiple places at once) |
| `s` (visual)     | Flash jump within the selection                              |
| `R` (visual)     | Treesitter Search: find & select multiple regions to edit at once |
| `gza`            | **Add** surround: wrap a selection in brackets/quotes/tags (`gza` + motion; visual: `gza` + input) |
| `gzd`            | **Delete** surround: delete the nearest pair (prompts for the type, e.g. `)`, `"`, `t` = tag) |
| `gzr`            | **Replace** surround: swap one pair for another              |
| `gzh`            | Highlight surround                                           |
| `gzn`            | Update the scan line count when searching for a distant surround |

> Note: flash takes over `s`/`S` (native substitute). Use `cl` (change line) / `cc` instead.

More powerful textobjects with mini.ai (combine with `i`/`a` as in `ci…`, `va…`, `di…`):

| Textobject | Scope                                   |
| ---------- | --------------------------------------- |
| `f`        | Function call — `cif` changes the arguments, `caf` the whole call |
| `a`        | Argument — `cia` changes one argument, `caa` the whole list |
| `t`        | HTML/JSX tag — `cit` changes the tag content |
| `?`        | Condition/if/while — `ci?`                |
| `_`        | The part between two `_` in a snake_case name |
| `(`/`)`, `[`, `{`, `'`, `` ` `` | Multi-line brackets/quotes, count-aware (`2i(` = skip 1 level) |

### Tests (`Space T`) — neotest

Works with Vitest/Jest (Angular, TS), pytest (Python), go test. Test debugging (`Space Td`) uses DAP: js-debug-adapter for Jest/Vitest, debugpy for pytest, delve for go test.

| Key             | Action                                    |
| --------------- | ----------------------------------------- |
| `Space Tt`      | Run the test at the cursor                |
| `Space Tf`      | Run all tests in the file                 |
| `Space Tp`      | Run all tests in the project              |
| `Space Td`      | **Debug test** with DAP (set breakpoints as usual) |
| `Space To`      | Output of the test under the cursor (hover) |
| `Space TO`      | Output window                             |
| `Space T<CR>`   | Test summary tree                         |
| `]T` / `[T`     | Jump to the next / previous test          |
| `Space TWt`     | **Watch** the test at the cursor (re-runs on save) |
| `Space TWf`     | Watch the whole file                      |
| `Space TWp`     | Watch the whole project                   |
| `Space TWS`     | Stop all watches                          |

> Karma/Jasmine (older Angular running in a browser) is not supported by neotest — use Vitest/Jest.

### LSP (enabled automatically per language)

| Key         | Action                            |
| ----------- | --------------------------------- |
| `K`         | Hover documentation               |
| `gd`        | Definition of symbol (picker)     |
| `gD`        | Declaration of symbol             |
| `gy`        | Type definition (quickfix list)   |
| `gI`        | Implementation (quickfix list)    |
| `grn`       | Rename symbol                     |
| `grr`       | References (snacks picker)        |
| `gri`       | Implementations (snacks picker)   |
| `grt`       | Type definition (snacks picker)   |
| `gra`       | Code action                       |
| `gO`        | Document symbols (outline)        |
| `gK`        | Signature help                    |
| `gl`        | Hover diagnostics                 |
| `]r` / `[r` | Next / previous reference of the symbol under the cursor |
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
| `Space gd`  | View diff (gitsigns, 1 file — vimdiff) |

#### Diff review & conflicts (diffview.nvim)

| Command                | Action                                                          |
| ---------------------- | --------------------------------------------------------------- |
| `:DiffviewOpen`        | Diff the working tree against git (`:DiffviewOpen HEAD~2`, `:DiffviewOpen main...feat` to pick a range/branch) |
| `:DiffviewFileHistory %` | Commit history of the current file (drop `%` for the whole repo) |
| `:DiffviewClose`       | Leave diffview and return to the previous buffer                |

During a merge/rebase, `:DiffviewOpen` lists conflicted files in the left panel and shows each conflict as a 3-way diff. For fast in-buffer resolution, use the git-conflict keys below. See also: `:h diffview-commands`.

#### Conflict resolution (git-conflict.nvim)

Conflict regions are highlighted in-buffer during merges/rebases. The keys below resolve the conflict under the cursor (ours/theirs/both also work on a visual selection):

| Key         | Action                   |
| ----------- | ------------------------ |
| `Space mo`  | Keep **ours**            |
| `Space mt`  | Keep **theirs**          |
| `Space mb`  | Keep **both**            |
| `Space m0`  | Keep **none**            |
| `]x` / `[x` | Next / previous conflict |

Commands like `:GitConflictChooseOurs`, `:GitConflictListQf` and `:GitConflictRefresh` are also available.

### Kubernetes (kubectl.nvim)

| Key / Command | Action                                             |
| ------------- | -------------------------------------------------- |
| `Space k`     | Toggle the kubectl panel (pods, logs, deploy, edit…) |
| `:Kubectx`    | Switch context                                    |
| `:Kubens`     | Switch namespace                                  |

Requires the `kubectl` binary on your machine (`brew install kubectl`).

### Nx (`Space N`) — nx-console.nvim

Browse Nx projects/targets and run them from the editor (needs an Nx monorepo with `node_modules` installed). Long-running targets (`serve`, `dev`, `watch`, `storybook`…) automatically run in a persistent bottom panel instead of a floating terminal. The `nxls` LSP (installed with `npm i -g nxls`, not via Mason) provides autocomplete for targets/executors inside `nx.json` and `project.json`.

| Key         | Action                                  |
| ----------- | --------------------------------------- |
| `Space Nx`  | Pick a project → run one of its targets |
| `Space Ne`  | Nx explorer sidebar (projects/targets)  |
| `Space Ng`  | Run a generator                         |
| `Space Nh`  | Recent tasks history                    |
| `Space Na`  | Run tasks affected by your changes      |
| `Space Nf`  | Project of the current file             |
| `Space Nr`  | Re-run the last task                    |
| `Space Ns`  | Stop running tasks                      |
| `Space NR`  | Refresh the Nx workspace                |
| `Space Np`  | Toggle the task panel                   |

`:NxGraph` opens the project graph in your browser; the other `:Nx*` commands mirror the keys above. The prefix is capital `N` — lowercase `Space n` is New File.

### AI Assistant (`Space a`) — avante.nvim

Cursor-style AI sidebar: ask questions about the open file, edit selections with a prompt, apply the suggested diffs in place. **The plugin only loads when `NVIM_AI_PROVIDER` is exported** — a machine that exports nothing skips it entirely, no keymaps taken. The exported value picks the backend (add more under `providers`/`acp_providers` in `lua/plugins/avante.lua`):

| `NVIM_AI_PROVIDER` | Mode              | Key to export                        | Notes                                        |
| ------------------ | ----------------- | ------------------------------------ | -------------------------------------------- |
| `zai`              | Chat sidebar      | `ZAI_API_KEY` (GLM Coding Plan)      | `glm-5.3` via the z.ai coding endpoint       |
| `openai`           | Chat sidebar      | `OPENAI_API_KEY`                     | `gpt-5.2` by default                         |
| `cursor`           | Cursor Agent (ACP)| `CURSOR_API_KEY` — or `agent login` once | needs Cursor's `agent` CLI on PATH        |

```sh
export NVIM_AI_PROVIDER=zai    # example: z.ai
export ZAI_API_KEY=...         # token for the provider above
export NVIM_AI_MODEL=glm-5.3   # optional: override the chat model (zai/openai)
```

nvim must be started from a shell that has these exports (launching from the GUI/Dock means no AI). In `cursor` mode the sidebar drives Cursor's agent instead of a plain chat model — pick the agent's model with `Space aM`.

| Key                  | Action                                        |
| -------------------- | --------------------------------------------- |
| `Space aa`           | Ask — open the sidebar with the current file as context |
| `Space aa` (visual)  | Ask about the selected code                   |
| `Space ae` (visual)  | Edit the selection from a prompt              |
| `Space an`           | New ask (fresh conversation)                  |
| `Space at`           | Toggle the sidebar                            |
| `Space af`           | Focus the sidebar                             |
| `Space ah`           | Pick a previous conversation (history)        |
| `Space a?`           | Switch model                                  |
| `Space aB`           | Add all open buffers to the chat context      |
| `Space aC`           | Toggle adding the current buffer/selection to the context |
| `Space aR`           | Show the repo map                             |
| `Space ar`           | Refresh the answer                            |
| `Space aS`           | Stop generating                               |
| `Space as`           | Toggle inline suggestion                      |
| `Space az`           | Zen mode                                      |
| `Space am` / ` aM`   | ACP (agentic) mode / pick the ACP model       |
| `Space ad`           | Toggle debug mode                             |

The sidebar itself has additional buffer-local keys (apply/reject the suggested diff, navigation) — see the [avante.nvim README](https://github.com/yetone/avante.nvim).

### Debug (DAP)

Debug Node/TS (`pwa-node`: launch the current file, run via `npx tsx`, or attach to a process), Go (delve: debug a package or a test file/package), Python (debugpy), Bash. `.vscode/launch.json` (if present) is loaded automatically.

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
| `Space uH`       | Inlay hints (global)              |
| `Space uf`       | Format on save (buffer)           |
| `Space ur`       | Reference highlighting            |
| `Space uY`       | Semantic highlight LSP (buffer)   |
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

Automatic: when you quit nvim, AstroNvim saves the **Last Session** + a **dirsession** (a separate session per folder). The next time you open nvim **without a file** in that folder → the session is restored automatically (buffers, windows, cwd). Opening with a file → no restore.

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
│       ├── astrocore.lua  # options, mappings, autocmds (session restore)
│       ├── astrolsp.lua   # LSP servers, format_on_save, inlay hints
│       ├── mason.lua      # tools auto-installed via Mason
│       ├── neotest.lua    # test adapters (vitest/jest, pytest, go)
│       ├── vtsls.lua      # vtsls perf + TS/JS inlay hints settings
│       ├── nx.lua         # Nx: nxls server + nx-console task runner
│       ├── avante.lua     # AI assistant (avante.nvim, gated on NVIM_AI_PROVIDER)
│       └── ...
└── lsp/
    └── angularls.lua      # angularls only attaches inside Angular projects
```

To add a new plugin: create a file `lua/plugins/<plugin-name>.lua`. To add/change keymaps: edit `mappings` in `lua/plugins/astrocore.lua`.
