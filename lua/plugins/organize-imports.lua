---@type LazySpec
return {
  "AstroNvim/astrocore",
  optional = true,
  opts = function(_, opts)
    local select_fmt = require "utils.format_modified"

    local TS_JS_PATTERNS = { "*.ts", "*.tsx", "*.mts", "*.cts", "*.js", "*.jsx", "*.mjs", "*.cjs" }

    local function modified_ranges(bufnr)
      local ok, gitsigns = pcall(require, "gitsigns")
      if not ok then return nil end
      local ok_hunks, hunks = pcall(gitsigns.get_hunks, bufnr)
      if not ok_hunks or hunks == nil then return nil end
      return select_fmt.ranges_from_hunks(hunks)
    end

    local function organize_imports(bufnr)
      local ok, vtsls = pcall(require, "vtsls")
      if not ok then return end
      if #vim.lsp.get_clients { bufnr = bufnr, name = "vtsls" } == 0 then return end
      local done = false
      vtsls.commands.organize_imports(bufnr, function() done = true end, function() done = true end)
      vim.wait(2000, function() return done end, 10)
    end

    local function format_modified_only(bufnr)
      local ranges = modified_ranges(bufnr)
      if ranges and #ranges == 0 then return end -- clean file: nothing to do
      local orig = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local ok_fmt = pcall(
        vim.lsp.buf.format,
        vim.tbl_extend("force", require("astrolsp").format_opts, {
          bufnr = bufnr,
          async = false,
        })
      )
      if not ok_fmt or ranges == nil then return end -- untracked: keep full format
      local formatted = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local final = select_fmt.selective_lines(orig, formatted, ranges)
      if not vim.deep_equal(final, formatted) then
        local cursors = {}
        for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
          cursors[win] = vim.api.nvim_win_get_cursor(win)
        end
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, final)
        for win, cursor in pairs(cursors) do
          if vim.api.nvim_win_is_valid(win) then
            local last = vim.api.nvim_buf_line_count(bufnr)
            vim.api.nvim_win_set_cursor(win, { math.min(cursor[1], last), cursor[2] })
          end
        end
      end
    end

    opts.autocmds = vim.tbl_deep_extend("force", opts.autocmds or {}, {
      organize_imports_modified_format = {
        {
          event = "BufWritePre",
          pattern = TS_JS_PATTERNS,
          desc = "TS/JS: organize imports, format only modified lines",
          callback = function(args)
            if vim.bo[args.buf].buftype ~= "" then return end
            format_modified_only(args.buf)
            organize_imports(args.buf)
          end,
        },
      },
    })
  end,
}
