-- Browse/manage Kubernetes from nvim (needs the kubectl binary)
-- :Kubectx / :Kubens switch context and namespace
return {
  "Ramilito/kubectl.nvim",
  version = "2.*", -- release ships pre-built binaries, no Rust toolchain needed
  dependencies = { "saghen/blink.lib" },
  cmd = { "Kubectl", "Kubectx", "Kubens" },
  keys = {
    {
      "<leader>k",
      function() require("kubectl").toggle() end,
      desc = "Kubectl",
    },
  },
  opts = {},
  config = function(_, opts) require("kubectl").setup(opts) end,
}
