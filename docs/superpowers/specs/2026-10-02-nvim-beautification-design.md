# Design: Làm đẹp toàn diện AstroNvim v6

- **Ngày:** 2026-10-02
- **Trạng thái:** Đã được user chấp nhận (phỏng vấn xong, hướng A)
- **Phạm vi:** UI/hiệu ứng ONLY — không đổi LSP, mappings, hay workflow hiện có

## Quyết định đã chốt với user

| Quyết định | Lựa chọn |
|---|---|
| Phạm vi | Làm đẹp toàn diện (dashboard, statusline, cmdline, indent, theme) |
| Theme | Giữ **catppuccin macchiato** |
| Nền | **Trong suốt** (`transparent_background = true`) |
| Hiệu ứng | **Full**: noice.nvim + mini.animate + mini.indentscope |
| Hướng triển khai | **A — AstroNvim-native**: giữ heirline, polish qua astroui; KHÔNG thay bằng lualine/bufferline.nvim |

## Các thành phần

### 1. Nền tảng theme — catppuccin trong suốt
**File:** sửa `lua/plugins/catppuccin.lua`

- `transparent_background = true`
- Bổ sung integrations còn thiếu (hiện chỉ có gitsigns, neotree, treesitter, notify, mini): `blink_cmp`, `flash`, `aerial`, `dap` + `dap_ui`, `indent_blankline`, `rainbow_delimiters`, `which_key`, `noice`
- Giữ `term_colors = true`

**Polish highlight** qua `astroui` (`highlights.init` trong `lua/plugins/astroui.lua`):
- `WinSeparator`: mảnh, màu mờ hơn mặc định
- `FloatBorder`/`NormalFloat`: đồng bộ màu border catppuccin
- Diagnostic virtual text: chỉnh độ tương phản để đọc được trên nền trong suốt

### 2. Dashboard — snacks.nvim
**File:** mới `lua/plugins/snacks.lua` — override `opts.dashboard` của snacks.nvim (đã có trong lazy-lock)

- Header: ASCII art con mèo, màu pastel catppuccin (đa sắc qua `hl` per-line)
- Quick actions: Find File, Recent Files (recent), New File, Restore Session (dùng resession — đã có trong config)
- Footer: quote ngẫu nhiên kiểu fortune (danh sách quote nội tuyến, không phụ thuộc `fortune` binary)
- Nút hoạt động với picker mặc định AstroNvim (`snacks.picker`)

### 3. Noice.nvim — cmdline & messages
**File:** mới `lua/plugins/noice.lua`

- Cmdline popup nổi (vị trí giữa-dưới màn hình), icon theo mode
- Messages + LSP progress → `mini` view góc trên phải
- **`popupmenu.enabled = false`** — giữ nguyên popupmenu của blink.cmp, tránh xung đột
- Routes: tách `vim Messages` khỏi hover docs; hover (`NoiceH`) giữ làm float gần cursor
- Tích hợp catppuccin (integration `noice = true` ở mục 1)

### 4. mini.indentscope — indent animation
**File:** mới `lua/plugins/mini-indentscope.lua`

- Ưu tiên: kiểm tra astrocommunity có pack `mini-indentscope` không; nếu có thì import từ community, nếu không thì spec trực tiếp `echasnovski/mini.indentscope`
- Dùng animation easing mặc định của mini (`gen_animation.quad`), không custom
- Chỉ hiển thị scope tại cursor (`options.try_as_path` tắt scope trong cây thư mục neo-tree)
- Disable trong buffer loại file không phù hợp (help, dashboard, mason, lazy...)

### 5. mini.animate — cursor mượt
**File:** mới `lua/plugins/mini-animate.lua`

- Bật module: **cursor** (duration ~100ms), **resize** window
- **Tắt module scroll** — tránh xung đột/double-animation với `smoothscroll = true` native (đặt trong `astrocore.lua:40`)
- Không dùng module fade

### 6. Statusline/bufferline polish
**File:** sửa `lua/plugins/astroui.lua` (chỉ thêm `highlights.init`, không đụng cấu trúc heirline)

- Tabline: buffer **active** nổi bật (bold + màu accent), buffer **inactive** mờ (màuComment-level)
- Giữ nguyên toàn bộ heirline components và mapping `<Leader>bd` (đang phụ thuộc `astroui.status.heirline`)

## Kiểm thử & xác minh

1. `nvim --headless "+Lazy! check" +qa` — không lỗi load
2. Mở nvim thường: dashboard hiển thị đúng ASCII art + actions hoạt động (Find File mở picker)
3. Mở file TS: indent animation chạy, rainbow delimiter, gitsigns blame như cũ
4. Gõ `:` cmdline → popup noice hiện; `:messages` → mini view
5. Di chuyển cursor `j/k`/`gg/G` → animation mượt, KHÔNG giật khi scroll (native smoothscroll đảm nhiệm)
6. Nền trong suốt: virtual text diagnostics + blame vẫn đọc được
7. Lint: chạy `selene` (repo có `selene.toml`) — không warning file mới

## Rủi ro & mitigation

| Rủi ro | Mitigation |
|---|---|
| noice xung đột blink.cmp | `popupmenu.enabled = false` |
| mini.animate scroll đè native smoothscroll | Disable module scroll trong config |
| Transparent làm mờ virtual text/blame | Override highlight diagnostic colors đậm hơn |
| noice chậm trên máy yếu | User đã chọn full effects, chấp nhận trade-off; cấu hình view tối giản |
| astrocommunity đổi đường dẫn pack | Verify đường dẫn trước khi import; fallback spec trực tiếp |

## Out of scope (YAGNI)

- Không thay heirline bằng lualine/bufferline.nvim (hướng B đã bị loại)
- Không thêm dropbar/breadcrumbs, colorful-winsep, zen-mode, cellular-automaton
- Không đổi theme thứ 2 / theme switcher
- Không đụng LSP, mappings, completion config
