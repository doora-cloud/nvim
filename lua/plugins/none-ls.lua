-- Extra none-ls sources that mason-null-ls does not auto-register:
-- shfmt has a builtin but no mason-null-ls package mapping,
-- jsonnetfmt has neither builtin nor mapping
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local nls = require "null-ls"
    local h = require "null-ls.helpers"
    local methods = require "null-ls.methods"
    opts.sources = vim.list_extend(opts.sources or {}, {
      nls.builtins.formatting.shfmt,
      h.make_builtin {
        name = "jsonnetfmt",
        meta = { url = "https://jsonnet.org", description = "Jsonnet formatter" },
        method = methods.internal.FORMATTING,
        filetypes = { "jsonnet" },
        generator_opts = { command = "jsonnetfmt", args = { "-" }, to_stdin = true },
        factory = h.formatter_factory,
      },
    })
    return opts
  end,
}
