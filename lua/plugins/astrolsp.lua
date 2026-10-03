---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = true, -- enable/disable inlay hints on start (toggle: <Leader>uh buffer / <Leader>uH global)
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    formatting = {
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          "typescript",
          "typescriptreact",
          "javascript",
          "javascriptreact",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        "eslint", -- let prettier handle formatting; eslint LSP formatting is slow on large projects
      },
      timeout_ms = 2000, -- prettier on large Angular templates can exceed 1s
    },
    servers = {},
    config = {
      -- ["*"] = { capabilities = {} }, -- modify default LSP client settings such as capabilities
    },
    handlers = {},
    mappings = {
      n = {
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        grr = {
          function() require("snacks").picker.lsp_references() end,
          desc = "References of cursor symbol",
          cond = "textDocument/references",
        },
        gri = {
          function() require("snacks").picker.lsp_implementations() end,
          desc = "Implementations of cursor symbol",
          cond = "textDocument/implementation",
        },
        grt = {
          function() require("snacks").picker.lsp_type_definitions() end,
          desc = "Type definition of cursor symbol",
          cond = "textDocument/typeDefinition",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client:supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
      },
    },
    on_attach = function(client, bufnr)
      if client.name == "vtsls" then client.server_capabilities.semanticTokensProvider = nil end
    end,
  },
}
