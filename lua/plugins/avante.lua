-- avante.nvim: Cursor-like AI assistant sidebar
--  * Provider & API key live in ~/.zshrc (no secrets in this repo):
--      export NVIM_AI_PROVIDER=...   # REQUIRED: plugin only loads when this is set (no fallback)
--                                     #   zai    -> chat via the z.ai coding endpoint (ZAI_API_KEY)
--                                     #   openai -> chat via api.openai.com (OPENAI_API_KEY)
--                                     #   cursor -> Cursor Agent over ACP (CURSOR_API_KEY or `agent login`)
--      export NVIM_AI_MODEL=glm-5.3  # optional model override (zai/openai chat providers)
--  * The token is a GLM Coding Plan token: it only works on the /coding/
--    endpoints (plain /api/paas/v4 returns "Insufficient balance").
--    Z.ai's coding endpoint is OpenAI-compatible, so the custom "zai"
--    provider inherits from the built-in "openai" one
-- Prefix is <Leader>a: <Leader>aa sidebar, <Leader>at toggle, <Leader>an new ask
--
-- NOTE (macOS): upstream prebuilt binaries link libiconv to a /nix/store path that
-- doesn't exist here (cargo 1.83 is also too old to build from source). After a
-- plugin update, re-download + patch with:
--   cd ~/.local/share/nvim/lazy/avante.nvim && bash build.sh && \
--   for f in lua/avante_*.so; do install_name_tool -change \
--     /nix/store/a85h00app701vf0ggln0r97yayszvwkk-libiconv-109.100.2/lib/libiconv.2.dylib \
--     /usr/lib/libiconv.2.dylib "$f" && codesign -f -s - "$f"; done
---@type LazySpec
return {
  {
    "yetone/avante.nvim",
    -- gate on NVIM_AI_PROVIDER: unset/empty env -> plugin never loads
    cond = vim.env.NVIM_AI_PROVIDER ~= nil and vim.env.NVIM_AI_PROVIDER ~= "",
    event = "VeryLazy",
    version = false, -- follow latest commit; README warns never to pin "*"
    build = "make", -- fetches the prebuilt binary via curl + tar
    opts = {
      provider = vim.env.NVIM_AI_PROVIDER,
      providers = {
        zai = {
          __inherited_from = "openai",
          endpoint = "https://api.z.ai/api/coding/paas/v4",
          model = vim.env.NVIM_AI_MODEL or "glm-5.3",
          api_key_name = "ZAI_API_KEY",
          timeout = 120000,
          context_window = 128000,
        },
        -- override only the default model of the built-in "openai" provider
        -- (endpoint + api_key_name OPENAI_API_KEY are inherited; models > 5.2
        -- drop tool-calling on the Chat Completions API)
        openai = { model = vim.env.NVIM_AI_MODEL or "gpt-5.2" },
      },
      -- agent providers (Agent Client Protocol): NVIM_AI_PROVIDER=cursor turns
      -- the sidebar into Cursor's agent, driven by Cursor's `agent` CLI.
      -- Auth: export CURSOR_API_KEY (API key) or run `agent login` once.
      acp_providers = {
        cursor = {
          command = "agent",
          args = { "acp" },
          env = { CURSOR_API_KEY = os.getenv "CURSOR_API_KEY" },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      { "ColinKennedy/mega.cmdparse", dependencies = { "ColinKennedy/mega.logging" } },
    },
  },
}
