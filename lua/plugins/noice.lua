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
