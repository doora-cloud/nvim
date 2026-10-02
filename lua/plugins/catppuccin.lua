return {
  "catppuccin/nvim",
  name = "catppuccin",
  opts = {
    flavour = "macchiato", --latte, frappe, macchiato, mocha
    transparent_background = false,
    term_colors = true,
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      notify = true,
      mini = {
        enabled = true,
        indentscope_color = "",
      },
    },
  },
}
