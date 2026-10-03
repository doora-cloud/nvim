---@type LazySpec
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      auto_clean_after_session_restore = true,
      window = {
        width = 38,
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          never_show = { ".git", ".DS_Store" },
        },
      },
    },
  },
}
