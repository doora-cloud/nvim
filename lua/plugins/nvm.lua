-- Auto-switch node to the project's .nvmrc ($PATH, $NVM_BIN, LSP restart)
---@type LazySpec
return {
  "AstroNvim/astrocore",
  optional = true,
  opts = function(_, opts)
    local nvm = require "utils.nvm"

    opts.autocmds = vim.tbl_deep_extend("force", opts.autocmds or {}, {
      nvmrc_switch = {
        {
          event = { "BufEnter", "DirChanged" },
          desc = "Use node version from project .nvmrc",
          callback = function(args) nvm.sync(args.buf, args.cwd) end,
        },
      },
    })
  end,
}
