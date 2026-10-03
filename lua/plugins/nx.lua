-- Nx workspace support:
--  * nxls: official Nx language server (autocomplete/diagnostics for nx.json,
--    project.json targets & executors). Binary installed globally via `npm i -g nxls`
--  * nx-console.nvim: browse projects/targets and run Nx tasks from the editor
-- Prefix is <Leader>N (capital): <Leader>n is AstroNvim's "New File" mapping
---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    opts = {
      servers = { "nxls" },
    },
  },
  {
    "willdavidow/nx-console.nvim",
    dependencies = {
      "folke/snacks.nvim",
      "MunifTanjim/nui.nvim",
    },
    cmd = {
      "NxProjects",
      "NxExplorer",
      "NxGenerate",
      "NxHistory",
      "NxAffected",
      "NxCurrentProject",
      "NxRerun",
      "NxStop",
      "NxRefresh",
      "NxPanel",
      "NxGraph",
    },
    -- both the lazy keys and opts.keys below must be kept in sync:
    -- lazy keys lazy-load the plugin, opts.keys override the plugin's own <leader>n* mappings
    keys = {
      { "<Leader>Nx", "<cmd>NxProjects<cr>", desc = "Nx projects" },
      { "<Leader>Ne", "<cmd>NxExplorer<cr>", desc = "Nx explorer" },
      { "<Leader>Ng", "<cmd>NxGenerate<cr>", desc = "Nx generate" },
      { "<Leader>Nh", "<cmd>NxHistory<cr>", desc = "Nx history" },
      { "<Leader>Na", "<cmd>NxAffected<cr>", desc = "Nx affected" },
      { "<Leader>Nf", "<cmd>NxCurrentProject<cr>", desc = "Nx project of current file" },
      { "<Leader>Nr", "<cmd>NxRerun<cr>", desc = "Nx rerun last task" },
      { "<Leader>Ns", "<cmd>NxStop<cr>", desc = "Nx stop tasks" },
      { "<Leader>NR", "<cmd>NxRefresh<cr>", desc = "Nx refresh workspace" },
      { "<Leader>Np", "<cmd>NxPanel<cr>", desc = "Nx task panel" },
    },
    opts = {
      keys = {
        projects = "<Leader>Nx",
        explorer = "<Leader>Ne",
        generate = "<Leader>Ng",
        history = "<Leader>Nh",
        affected = "<Leader>Na",
        current = "<Leader>Nf",
        rerun = "<Leader>Nr",
        stop = "<Leader>Ns",
        refresh = "<Leader>NR",
        panel = "<Leader>Np",
      },
    },
    -- the plugin hardcodes a which-key group under <leader>n (AstroNvim's "New File"
    -- key); which-key specs registered later replace earlier ones for the same lhs,
    -- so relabel it after setup and put the group on our <Leader>N prefix instead
    config = function(_, opts)
      require("nx").setup(opts)
      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.add { { "<leader>n", desc = "New File" } }
        wk.add { { "<Leader>N", group = "Nx" } }
      end
    end,
  },
}
