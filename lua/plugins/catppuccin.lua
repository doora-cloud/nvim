return {
  "catppuccin/nvim",
  name = "catppuccin",
  opts = {
    flavour = "macchiato", --latte, frappe, macchiato, mocha
    transparent_background = false,
    term_colors = true,
    integrations = {
      gitsigns = true,
      neotree = true,
      treesitter = true,
      notify = true,
      mini = {
        enabled = true,
        indentscope_color = "",
      },
    },
  },
}
