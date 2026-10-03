-- scroll + resize animation and the wheel-scroll guard (which disables
-- animation while scrolling with the mouse) come from the
-- astrocommunity.scrolling.mini-animate spec — do not override opts.scroll
-- here or the guard gets wiped. Cursor animation is disabled because it
-- restarts mid-scroll whenever 'scrolloff' repositions the cursor.
---@type LazySpec
return {
  "echasnovski/mini.animate",
  opts = function(_, opts)
    opts.cursor = { enable = false }
    return opts
  end,
}
