-- neotest adapters for the languages this config targets.
-- Keybinds come from the astrocommunity spec: <Leader>T prefix (run/debug/watch).
-- NOTE: neotest only reads `opts.adapters` as an ARRAY (ipairs); string-keyed
-- entries are silently ignored, and a table-valued `opts.adapters` fragment
-- also replaces any list a previous spec built — so always mutate the list
-- inside an opts function (verified 2026-10-02). neotest-jest is NOT added
-- here because the astrocommunity typescript pack already inserts it.
---@type LazySpec
return {
  "nvim-neotest/neotest",
  dependencies = {
    "marilari88/neotest-vitest",
    "nvim-neotest/neotest-jest",
    "nvim-neotest/neotest-go",
    "nvim-neotest/neotest-python",
  },
  opts = function(_, opts)
    opts.adapters = opts.adapters or {}
    vim.list_extend(opts.adapters, {
      -- Angular >= 17 (vitest) and plain vitest projects
      require("neotest-vitest") {},
      require("neotest-python") { runner = "pytest", dap = { justMyCode = false } },
      require("neotest-go") {},
    })
  end,
}
