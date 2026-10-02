-- Node.js / TypeScript + Go debugging.
-- Keymaps and the debug UI come from AstroNvim v6's bundled nvim-dap spec
-- (<Leader>d prefix), and .vscode/launch.json is picked up automatically.
--
-- NOTE: `pwa-node` must be registered manually — mason-nvim-dap's mapping for
-- js-debug-adapter expects the legacy adapter name "js" and ships no adapter
-- definition for it, so nothing gets auto-registered (verified 2026-10-02).
-- Registering "pwa-node" also lets neotest debug jest/vitest tests with
-- <Leader>Td (both adapters hardcode type = "pwa-node").
--
-- Go: the "delve" Mason package is auto-registered by mason-nvim-dap together
-- with its launch configurations (type = "delve"), but neotest-go's debug
-- strategy hardcodes type = "go", so alias it to the same dlv server config.
---@type LazySpec
return {
  "mfussenegger/nvim-dap",
  optional = true,
  opts = function()
    local dap = require "dap"
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = { command = "js-debug-adapter", args = { "${port}" } },
    }
    dap.adapters.go = {
      type = "server",
      port = "${port}",
      executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
    }
    local configs = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch current file",
        program = "${file}",
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
      },
      {
        -- for TS projects on Node without native type stripping
        type = "pwa-node",
        request = "launch",
        name = "Launch current file (tsx)",
        runtimeExecutable = "npx",
        runtimeArgs = { "tsx", "${file}" },
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach to process",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
      },
    }
    for _, ft in ipairs { "javascript", "typescript", "javascriptreact", "typescriptreact" } do
      dap.configurations[ft] = configs
    end
  end,
}
