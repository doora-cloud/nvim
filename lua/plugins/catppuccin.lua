return {
  "catppuccin/nvim",
  name = "catppuccin",
  opts = {
    flavour = "macchiato", --latte, frappe, macchiato, mocha
    transparent_background = false, -- solid background for better contrast
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
      rainbow_delimiters = true,
      snacks = true,
      treesitter = true,
      which_key = true,
    },
  },
}
