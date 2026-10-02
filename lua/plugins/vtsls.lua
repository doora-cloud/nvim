-- Extra vtsls performance settings, deep-merged by lazy.nvim on top of
-- the astrocommunity typescript pack defaults
---@type LazySpec
return {
  "AstroNvim/astrolsp",
  optional = true,
  opts = {
    config = {
      vtsls = {
        settings = {
          vtsls = {
            -- prefer the workspace's own TypeScript from node_modules over the bundled one
            autoUseWorkspaceTsdk = true,
            experimental = {
              completion = {
                -- filter completion items server-side to reduce LSP payload
                enableServerSideFuzzyMatch = true,
                entriesLimit = 50,
              },
            },
          },
          -- inlay hints (shown because astrolsp features.inlay_hints = true;
          -- same shape as VSCode's typescript/javascript.inlayHints.*)
          typescript = {
            inlayHints = {
              parameterNames = { enabled = "literals", suppressWhenArgumentMatchesName = true },
              functionLikeExpressionTypes = { enabled = true },
              enumMemberValues = { enabled = true },
              -- kept off: noisy
              variableTypes = { enabled = false },
              propertyDeclarationTypes = { enabled = false },
            },
          },
          javascript = {
            inlayHints = {
              parameterNames = { enabled = "literals", suppressWhenArgumentMatchesName = true },
              functionLikeExpressionTypes = { enabled = true },
              enumMemberValues = { enabled = true },
              variableTypes = { enabled = false },
              propertyDeclarationTypes = { enabled = false },
            },
          },
        },
      },
    },
  },
}
