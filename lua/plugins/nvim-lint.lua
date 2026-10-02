-- Linters wired through nvim-lint instead of none-ls:
-- none-ls dropped its shellcheck builtin and mason-null-ls has no
-- source mapping for the installed binary. tflint needs no entry here,
-- AstroNvim auto-enables it as an LSP langserver from the Mason package
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require "lint"
    lint.linters_by_ft = {
      sh = { "shellcheck" },
    }

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("user_nvim_lint", { clear = true }),
      callback = function() lint.try_lint() end,
    })
  end,
}
