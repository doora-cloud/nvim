# Nvim Beautification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Làm đẹp toàn diện AstroNvim v6: catppuccin trong suốt + full integrations, dashboard custom, noice.nvim, mini.indentscope, mini.animate, highlight polish — theo spec `docs/superpowers/specs/2026-10-02-nvim-beautification-design.md`.

**Architecture:** Hướng A — AstroNvim-native. Giữ heirline nguyên vẹn; thêm plugin qua astrocommunity imports (`astrocommunity.utility.noice-nvim`, `astrocommunity.indent.mini-indentscope`, `astrocommunity.scrolling.mini-animate` — đã verify tồn tại trong bản astrocommunity đang cài); override opts qua file mới trong `lua/plugins/`.

**Tech Stack:** AstroNvim v6, lazy.nvim, catppuccin macchiato, snacks.nvim (dashboard), noice.nvim, mini.\* plugins. Neovim 0.12.5, macOS.

## Global Constraints

- KHÔNG thay thế heirline bằng lualine/bufferline.nvim (spec: hướng A)
- Giữ theme `catppuccin`, flavour `macchiato`
- Comment trong code viết bằng TIẾNG ANH (theo convention của toàn repo)
- Repo CÓ sẵn các thay đổi chưa commit khác (`lua/community.lua`, `astrocore.lua`, `astrolsp.lua`, `mason.lua`, `vtsls.lua`, `lazy-lock.json`, các file mới khác) — mỗi task CHỈ `git add` đúng file của task đó. Riêng `lazy-lock.json` bị dirty từ trước, chỉ commit ở Task 7 kèm ghi chú
- Comment style: `-- comment` không space đầu sau `--` (theo stylua convention của AstroNvim templates, vd `-- sets vim.opt.number`)
- Không có selene/stylua binary → verification bằng `nvim --headless`
- `lua/community.lua` import community packs TRƯỚC khi `lua/plugins/` được load (lazy_setup.lua đảm bảo) — override files hợp lệ

## Verified Facts (điều tra từ plugins đã cài — executor không cần verify lại)

- `astrocommunity/lua/astrocommunity/utility/noice-nvim/` tồn tại; pack tự set catppuccin `integrations.noice = true`, tự disable astrolsp hover/signature handlers, presets: bottom_search + command_palette + long_message_to_split
- `astrocommunity/lua/astrocommunity/indent/mini-indentscope/` tồn tại; pack tự disable ibl scope (`scope = { enabled = false }`), tự thêm catppuccin `integrations.mini = true`, tự disable ở filetypes (help/lazy/neo-tree/...)
- `astrocommunity/lua/astrocommunity/scrolling/mini-animate/` tồn tại; pack bật cursor (80ms), scroll (150ms), resize (100ms); `cond = not (vim.g.neovide or vim.g.vscode)`
- AstroNvim core đang bật `snacks.indent` + `snacks.scope` (opts merged `enabled = true` — đã dump runtime). Cùng ibl đang chạy → khi thêm mini.indentscope sẽ thành 3 scope renderer → PHẢI disable snacks.indent + snacks.scope (Task 4)
- catppuccin integration names đúng (verify từ `lua/catppuccin/groups/integrations/`): `blink_cmp`, `flash`, `aerial`, `dap`, `dap_ui`, `indent_blankline`, `rainbow_delimiters`, `which_key`, `noice`, `snacks`. `snacks` integration define sẵn `SnacksDashboardHeader` (blue), `SnacksDashboardFooter` (yellow italic), `SnacksDashboardIcon` (pink bold), `SnacksDashboardKey` (peach)
- snacks dashboard custom section: field `text` nhận `snacks.dashboard.Text[]` với mỗi Text = `{ [1] = string, hl = string }`; KHÔNG nhận function trong `text` → quote random phải tính sẵn trong opts function
- lazy.nvim merge opts array THEO INDEX → mọi override dashboard phải provide ĐẦY ĐỦ array (keys, sections), không được provide một phần
- `nui.nvim` (dep của noice) đã cài trong lazy-lock
- ibl scope rainbow underline sẽ mất khi mini.indentscope pack disable ibl scope (đổi lấy animated scope line) — đã chấp nhận trong spec
- Mapping `<Leader>u|` (toggle snacks indent guides) trở nên vô nghĩa sau khi disable snacks.indent — known behavior change, chấp nhận

---

### Task 1: catppuccin trong suốt + full integrations

**Files:**
- Modify: `lua/plugins/catppuccin.lua` (replace toàn bộ opts)

**Interfaces:**
- Consumes: không (task đầu)
- Produces: catppuccin opts với `transparent_background = true` + đầy đủ integrations; các integration name cho Task 3/4 rely (noice/snacks integration được bật tự động bởi packs, không cần trong file này trừ `noice`)

- [ ] **Step 1: Replace nội dung `lua/plugins/catppuccin.lua`**

```lua
return {
  "catppuccin/nvim",
  name = "catppuccin",
  opts = {
    flavour = "macchiato", --latte, frappe, macchiato, mocha
    transparent_background = true, -- show terminal wallpaper/blur behind nvim
    term_colors = true,
    integrations = {
      aerial = true,
      blink_cmp = true,
      dap = true,
      dap_ui = true,
      flash = true,
      gitsigns = true,
      indent_blankline = true,
      mini = {
        enabled = true,
        indentscope_color = "",
      },
      neotree = true,
      noice = true,
      notify = true,
      rainbow_delimiters = true,
      snacks = true,
      treesitter = true,
      which_key = true,
    },
  },
}
```

- [ ] **Step 2: Verify load không lỗi + transparent được set**

```bash
nvim --headless "+lua vim.cmd.colorscheme('catppuccin')" "+lua local ok = pcall(vim.api.nvim_get_hl_by_name, 'Normal', true); assert(ok); print('HL_OK')" +qa
```

Expected output: `HL_OK`, exit 0, không có stack trace lỗi.

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/catppuccin.lua
git commit -m "feat(ui): enable transparent catppuccin with full integrations"
```

---

### Task 2: astroui highlight polish

**Files:**
- Modify: `lua/plugins/astroui.lua` (chỉ thêm vào `highlights.init`)

**Interfaces:**
- Consumes: không
- Produces: highlights.init override `WinSeparator` (overlay0 `#6e738d`), `FloatBorder` (blue `#8aadf4`) — hardcode hex của macchiato vì user chỉ dùng catppuccin; các task sau không phụ thuộc

- [ ] **Step 1: Sửa block `highlights.init` trong `lua/plugins/astroui.lua`**

Thay:

```lua
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- Normal = { bg = "#000000" },
      },
```

bằng:

```lua
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- hex colors are catppuccin macchiato palette (only theme in use)
        WinSeparator = { fg = "#6e738d" }, -- overlay0: subtle thin separators
        FloatBorder = { fg = "#8aadf4" }, -- blue: consistent float borders
      },
```

- [ ] **Step 2: Verify highlight được áp dụng**

```bash
nvim --headless "+lua vim.cmd.colorscheme('catppuccin')" "+lua local hl = vim.api.nvim_get_hl(0, { name = 'WinSeparator' }); assert(hl.fg == 0x6e738d, 'fg mismatch: ' .. tostring(hl.fg)); print('SEP_OK')" +qa
```

Expected: `SEP_OK` (0x6e738d = 7238605). Nếu assert fail → kiểm tra hex.

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/astroui.lua
git commit -m "feat(ui): subtle window separators and consistent float borders"
```

---

### Task 3: Import astrocommunity packs (noice, mini-indentscope, mini-animate)

**Files:**
- Modify: `lua/community.lua` (thêm 3 imports cuối file)

**Interfaces:**
- Consumes: không
- Produces: 3 plugin specs (folke/noice.nvim, echasnovski/mini.indentscope, echasnovski/mini.animate) để Task 4/5/6 override opts merge vào; pack tự bật catppuccin `noice` integration (đã có ở Task 1, no-op) + tự disable astrolsp hover/signature handlers

LƯU Ý: file này đang DIRTY từ session trước (có diff chưa commit). CHỈ THÊM 3 dòng import — không đụng nội dung có sẵn, commit nguyên file (diff cũ + 3 dòng mới đi cùng commit là chấp nhận được vì chúng là config state hợp lệ của user).

- [ ] **Step 1: Thêm imports vào cuối `lua/community.lua`** (sau dòng `{ import = "astrocommunity.test.neotest" },`)

```lua
-- eye candy: fancy cmdline/messages, animated indent scope, smooth cursor
{ import = "astrocommunity.utility.noice-nvim" },
{ import = "astrocommunity.indent.mini-indentscope" },
{ import = "astrocommunity.scrolling.mini-animate" },
```

- [ ] **Step 2: Sync plugins và verify cài đặt**

```bash
nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5
```

Expected: exit 0. Sau đó:

```bash
ls ~/.local/share/nvim/lazy | grep -E "^(noice.nvim|mini.indentscope|mini.animate)$"
```

Expected output đủ 3 dòng:
```
mini.animate
mini.indentscope
noice.nvim
```

- [ ] **Step 3: Verify headless startup không lỗi (noice/mini load trên VeryLazy)**

```bash
nvim --headless "+lua print('STARTUP_OK')" +qa 2>&1 | grep -E "STARTUP_OK|Error|E[0-9]+" ; echo "exit=$?"
```

Expected: dòng `STARTUP_OK` hiện ra, không có `Error`/`E###`.

- [ ] **Step 4: Commit**

```bash
git add lua/community.lua
git commit -m "feat(ui): import noice, mini.indentscope, mini.animate from astrocommunity"
```

---

### Task 4: Custom snacks dashboard + disable snacks.indent/scope

**Files:**
- Create: `lua/plugins/snacks.lua`

**Interfaces:**
- Consumes: snacks.nvim core spec của AstroNvim (opts function set dashboard/indent/scope/...; merge table-of-user đè lên kết quả function); `SnacksDashboard*` hl groups từ catppuccin `snacks` integration (Task 1)
- Produces: `opts.dashboard` hoàn chỉnh (header cat ASCII, 6 keys, footer quote, startup section); `opts.indent.enabled = false`, `opts.scope.enabled = false` để tránh 3 lớp indent (ibl + snacks + mini.indentscope từ Task 3)

- [ ] **Step 1: Tạo file `lua/plugins/snacks.lua`** (viết đúng phiên bản cuối này — `text` không nhận function nên quote random được tính sẵn trong opts function)

```lua
-- custom dashboard + hand indent rendering to indent-blankline + mini.indentscope
local quotes = {
  "Simplicity is prerequisite for reliability. — Edsger W. Dijkstra",
  "Programs must be written for people to read. — SICP",
  "Make it work, make it right, make it fast. — Kent Beck",
  "The best error message is the one that never shows up. — Thomas Fuchs",
  "First, solve the problem. Then, write the code. — John Johnson",
  "Deleted code is debugged code. — Jeff Sickel",
  "Talk is cheap. Show me the code. — Linus Torvalds",
  "Any fool can write code that a computer can understand. — Martin Fowler",
}

---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    -- AstroNvim enables snacks.indent/snacks.scope by default; we already have
    -- indent-blankline + rainbow-delimiters + mini.indentscope, so disable them
    -- to avoid rendering three overlapping indent layers
    opts.indent = { enabled = false }
    opts.scope = { enabled = false }

    opts.dashboard = {
      preset = {
        header = table.concat({
          "      /\\_____/\\",
          "     /  o   o  \\",
          "    ( ==  ^  == )",
          "     )         (",
          "    (           )",
          "   ( (  )   (  ) )",
          "  (__(__)___(__)__)",
        }, "\n"),
        keys = {
          { key = "f", action = "<Leader>ff", icon = "󰈞", desc = "Find File  " },
          { key = "o", action = "<Leader>fo", icon = "󰄉", desc = "Recents  " },
          { key = "n", action = "<Leader>n", icon = "󰝒", desc = "New File  " },
          { key = "w", action = "<Leader>fw", icon = "󰊄", desc = "Find Word  " },
          { key = "'", action = "<Leader>f'", icon = "󰃀", desc = "Bookmarks  " },
          { key = "s", action = "<Leader>Sl", icon = "󰦛", desc = "Last Session  " },
        },
      },
      sections = {
        { section = "header", padding = 5 },
        { section = "keys", gap = 1, padding = 3 },
        { text = { { "  " .. quotes[math.random(#quotes)], hl = "SnacksDashboardFooter" } }, align = "center" },
        { section = "startup" },
      },
    }
    return opts
  end,
}
```

- [ ] **Step 2: Verify opts merge đúng ý**

```bash
nvim --headless "+lua local o = require('astrocore').plugin_opts('snacks.nvim'); assert(o.indent.enabled == false, 'indent not disabled'); assert(o.scope.enabled == false, 'scope not disabled'); assert(o.dashboard.preset.header:find('o   o'), 'header missing'); assert(#o.dashboard.sections == 4, 'sections count'); print('SNACKS_OK')" +qa
```

Expected: `SNACKS_OK`.

- [ ] **Step 3: Verify dashboard mở được**

```bash
nvim --headless "+lua require('snacks').dashboard()" "+sleep 300m" "+lua assert(vim.bo.filetype == 'snacks_dashboard', 'ft=' .. vim.bo.filetype); print('DASH_OK')" +qa
```

Expected: `DASH_OK`.

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/snacks.lua
git commit -m "feat(ui): custom cat dashboard and single indent renderer"
```

---

### Task 5: noice override — giữ popupmenu của blink.cmp

**Files:**
- Create: `lua/plugins/noice.lua`

**Interfaces:**
- Consumes: noice spec từ `astrocommunity.utility.noice-nvim` (Task 3) — đã set presets + catppuccin integration + astrolsp handler disabling
- Produces: `opts.popupmenu.enabled = false` (blink.cmp tự render menu riêng, không qua noice)

- [ ] **Step 1: Tạo file `lua/plugins/noice.lua`**

```lua
-- blink.cmp renders its own popup menu; keep noice off that path
---@type LazySpec
return {
  "folke/noice.nvim",
  opts = {
    popupmenu = {
      enabled = false,
    },
  },
}
```

- [ ] **Step 2: Verify merged opts**

```bash
nvim --headless "+lua local o = require('astrocore').plugin_opts('noice.nvim'); assert(o.popupmenu.enabled == false, 'popupmenu not disabled'); assert(o.presets.command_palette == true, 'community presets lost'); print('NOICE_OK')" +qa
```

Expected: `NOICE_OK` (chứng minh merge giữ được presets của pack + override của ta).

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/noice.lua
git commit -m "feat(ui): noice cmdline/messages with native blink popup menu"
```

---

### Task 6: mini.animate override — tắt scroll, cursor 100ms

**Files:**
- Create: `lua/plugins/mini-animate.lua`

**Interfaces:**
- Consumes: mini.animate spec từ `astrocommunity.scrolling.mini-animate` (Task 3) — opts function trả về cursor 80ms/scroll 150ms/resize 100ms
- Produces: `opts.scroll.enabled = false` (tránh double-animation với `smoothscroll = true` native trong astrocore.lua), `opts.cursor.timing` duration 100ms theo spec

- [ ] **Step 1: Tạo file `lua/plugins/mini-animate.lua`**

```lua
-- native smoothscroll (astrocore options.opt.smoothscroll) already animates
-- scrolling; only animate cursor movement and window resize here
---@type LazySpec
return {
  "echasnovski/mini.animate",
  opts = function(_, opts)
    local animate = require "mini.animate"
    opts.scroll = { enabled = false }
    opts.cursor = { timing = animate.gen_timing.linear { duration = 100, unit = "total" } }
    return opts
  end,
}
```

- [ ] **Step 2: Verify merged opts**

```bash
nvim --headless "+lua local o = require('astrocore').plugin_opts('mini.animate'); assert(o.scroll.enabled == false, 'scroll not disabled'); assert(o.cursor.timing, 'cursor timing missing'); assert(o.resize.timing, 'resize timing from pack lost'); print('ANIMATE_OK')" +qa
```

Expected: `ANIMATE_OK`.

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/mini-animate.lua
git commit -m "feat(ui): smooth cursor animation, defer scrolling to native smoothscroll"
```

---

### Task 7: Xác minh tổng thể + lock file

**Files:**
- Modify: `lazy-lock.json` (do `Lazy sync` ở Task 3; có thể dirty từ session trước — commit toàn bộ ở đây kèm ghi chú)

**Interfaces:**
- Consumes: tất cả task trước
- Produces: config hoàn chỉnh, lock file cập nhật

- [ ] **Step 1: Full headless startup sạch**

```bash
nvim --headless "+lua print('FULL_OK')" +qa 2>&1 | grep -E "FULL_OK|Error|E[0-9]+"
```

Expected: chỉ `FULL_OK`, không Error/E-codes.

- [ ] **Step 2: Verify các plugin chính đã load + config cũ nguyên vẹn**

```bash
nvim --headless "+lua assert(pcall(require,'noice'), 'noice not loaded'); assert(pcall(require,'mini.animate'), 'mini.animate not loaded'); assert(pcall(require,'mini.indentscope'), 'mini.indentscope not loaded')" \
  "+lua local gs = require('astrocore').plugin_opts('gitsigns.nvim'); assert(gs.current_line_blame == true, 'gitsigns blame lost')" \
  "+lua local ac = require('astrocore').plugin_opts('astrocore'); assert(ac.options.opt.smoothscroll == true, 'smoothscroll lost')" \
  "+lua print('INTEGRITY_OK')" +qa
```

Expected: `INTEGRITY_OK`.

- [ ] **Step 3: Verify bằng mắt (báo user tự chạy — không automate được)**

Chạy `nvim` thường (KHÔNG headless) và checklist:
1. Dashboard: mèo ASCII màu xanh pastel, 6 phím tắt, quote footer
2. Nhấn `f` → snacks picker mở Find File
3. Mở file `.ts`: vạch indent có scope line chạy animation tại cursor; rainbow delimiter màu
4. Gõ `:` → cmdline popup noice; `K` hover → docs có border
5. `j/k`, `gg/G` → cursor trượt mượt; `<C-d>` scroll KHÔNG double-animate
6. Nền trong suốt; gitsigns blame cuối dòng vẫn đọc được
7. Blink cmp popup (`:` gõ vài ký tự? mở cmp bằng insert) vẫn render bình thường (không phải noice)

- [ ] **Step 4: Commit lock file**

```bash
git add lazy-lock.json
git commit -m "chore: update lazy-lock after beautification plugins"
```

(Lock file dirty từ session TS-LSP trước — phần diff đó là config state hợp lệ đã chạy tốt, gộp chung commit.)

## Self-Review (đã chạy khi viết plan)

1. **Spec coverage:** theme transparent+integrations (T1), highlight polish (T2), noice (T3+T5), dashboard (T4), mini.indentscope (T3), mini.animate (T3+T6), verification (T7) ✓. Spec mục "Tabline buffer active nổi bật" — heirline core đã có sẵn phân biệt active/inactive (`_astroui_status.lua:189-194`), spec ghi "polish nhẹ, không đổi plugin" → covered by T2 polish, không cần thêm task
2. **Placeholder scan:** không có TBD/TODO; mọi step có code/command đầy đủ ✓
3. **Type consistency:** integration names khớp catppuccin source; astrocommunity import paths khớp filesystem; snacks Text shape `{ [1], hl }` khớp dashboard.lua:48-51 ✓
