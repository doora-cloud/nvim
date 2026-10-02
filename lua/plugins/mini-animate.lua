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
