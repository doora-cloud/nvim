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

    -- grr/gri/grt (lsp references/implementations/type definitions): always
    -- keep the floating popup with list left + preview right; snacks falls
    -- back to a vertical (preview-bottom) layout when the window is narrower
    -- than 120 columns
    opts.picker = {
      sources = {
        lsp_references = { layout = { preset = "telescope" } },
        lsp_implementations = { layout = { preset = "telescope" } },
        lsp_type_definitions = { layout = { preset = "telescope" } },
      },
    }

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
