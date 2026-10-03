-- Merge/rebase conflict markers: highlight conflicting regions and resolve
-- them in-buffer. Pairs with diffview for reviewing the surrounding diff.
-- NOTE: not available in the pinned astrocommunity, so wired directly.
-- Keymap rationale: plugin defaults (co/ct/cb/c0) shadow native change
-- motions (ct{char}, cb, c0) and <Leader>g is fully taken by core/snacks,
-- so the "merge" prefix <Leader>m + ]x/[x navigation is used instead.
---@type LazySpec
return {
  "akinsho/git-conflict.nvim",
  version = "*",
  opts = {
    default_mappings = {
      ours = "<Leader>mo",
      theirs = "<Leader>mt",
      both = "<Leader>mb",
      none = "<Leader>m0",
      next = "]x",
      prev = "[x",
    },
    -- NOTE: keep disable_diagnostics unset (default false): the plugin calls
    -- vim.diagnostic.disable(), removed in Neovim 0.12 — setting it true
    -- crashes the GitConflictDetected handler and blocks the buffer
    -- mappings (verified 2026-10-03; unfixed upstream at v2.1.0).
  },
}
