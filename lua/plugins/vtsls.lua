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
        },
      },
    },
  },
}
