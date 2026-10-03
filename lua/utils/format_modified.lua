local M = {}

function M.ranges_from_hunks(hunks)
  local ranges = {}
  for _, hunk in ipairs(hunks or {}) do
    local added = hunk.added or {}
    if (added.count or 0) > 0 then ranges[#ranges + 1] = { added.start, added.start + added.count - 1 } end
  end
  return ranges
end

local function hit_any(ranges, s, e)
  for _, r in ipairs(ranges) do
    if s <= r[2] and r[1] <= e then return true end
  end
  return false
end

--- Keep only those formatting changes that overlap `ranges`.
--- All ranges are 1-based inclusive line numbers **in `orig`** coordinates.
--- Returns a new line list; equals `orig` when no formatting change touches
--- a modified range.
---@param orig string[] buffer lines before formatting
---@param formatted string[] buffer lines after formatting
---@param ranges table[] 1-based inclusive modified ranges (in `orig` coords)
---@return string[] merged lines
function M.selective_lines(orig, formatted, ranges)
  if #ranges == 0 then return vim.deepcopy(orig) end

  -- collect vim.diff hunks; indices are 1-based. For a pure insertion
  -- count_o == 0 and start_o is the line *after which* text is inserted.
  local hunks = {}
  vim.diff(table.concat(orig, "\n"), table.concat(formatted, "\n"), {
    on_hunk = function(start_o, count_o, start_n, count_n)
      hunks[#hunks + 1] = { start_o = start_o, count_o = count_o, start_n = start_n, count_n = count_n }
    end,
  })

  local final = vim.deepcopy(orig)
  for i = #hunks, 1, -1 do
    local h = hunks[i]
    local from, to = h.start_o, h.start_o + h.count_o - 1 -- replaced orig lines
    if h.count_o == 0 then
      from, to = h.start_o + 1, h.start_o
    end -- pure insertion: empty span after line `start_o`
    local first, last = h.start_n, h.start_n + h.count_n - 1 -- replacement text
    local probe_s, probe_e = from, to
    if h.count_o == 0 then
      probe_s, probe_e = h.start_o, h.start_o + 1
    end
    if hit_any(ranges, probe_s, probe_e) then
      local updated = {}
      for l = 1, from - 1 do
        updated[#updated + 1] = final[l]
      end
      if h.count_o == h.count_n and h.count_o > 0 then
        for l = from, to do
          if hit_any(ranges, l, l) then
            updated[#updated + 1] = formatted[first + l - from]
          else
            updated[#updated + 1] = final[l]
          end
        end
      else
        for l = first, last do
          updated[#updated + 1] = formatted[l]
        end
      end
      for l = to + 1, #final do
        updated[#updated + 1] = final[l]
      end
      final = updated
    end
  end
  return final
end

return M
