-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        "lua-language-server",
        "vtsls",
        "angular-language-server",
        "basedpyright",
        "gopls",
        "eslint-lsp",
        "json-lsp",
        "yaml-language-server",
        "helm-ls",
        "dockerfile-language-server",
        "docker-compose-language-service",
        "bash-language-server",
        "ansible-language-server",
        "terraform-ls",
        "taplo",
        "marksman",
        "jsonnet-language-server",

        -- install formatters / linters
        "stylua",
        "ruff",
        "ansible-lint",
        "jsonnetfmt",

        -- install debuggers
        "debugpy",
        "js-debug-adapter",
        "delve",

        -- install any other package
        "tree-sitter-cli",
      },
    },
  },
}
