-- Without an explicit root_dir the default root_markers fallback makes
-- angularls attach to every typescript/html file, even outside Angular
-- projects, so only attach when an actual Angular workspace is found.
---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { "angular.json", "nx.json" })
    if root then on_dir(root) end
  end,
}
