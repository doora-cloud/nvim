-- Switch Neovim's node to the version pinned in a project's .nvmrc.
-- Repoints $PATH/$NVM_BIN/$NVM_INC so everything Neovim spawns afterwards
-- (LSP servers, formatters, :terminal) uses it. Running LSP servers are
-- restarted since they keep the environment they were started with.
local M = {}

local nvm_dir = vim.fs.normalize(vim.env.NVM_DIR or (vim.env.HOME .. "/.nvm"))
local versions_dir = nvm_dir .. "/versions/node"
local nvm_bin_pat = "^" .. vim.pesc(versions_dir) .. "/v%d+%.%d+%.%d+/bin$"

-- spec -> resolved "x.y.z" | false (unresolvable), so each spec costs at most
-- one `nvm version` subshell per session
local resolved = {}

local applied -- version currently first on $PATH (nil = untouched)

local function read_spec(root)
  local file = root .. "/.nvmrc"
  if vim.fn.filereadable(file) == 0 then return nil end
  local spec = vim.trim((vim.fn.readfile(file))[1] or "")
  if spec == "" then return nil end
  return spec
end

local function resolve(spec)
  if resolved[spec] ~= nil then return resolved[spec] end
  local version = spec:match "^v?(%d+%.%d+%.%d+)$"
  if not version then
    -- partial version or alias (e.g. "20", "lts/jod"): let nvm resolve it
    local out = vim.trim(
      vim.fn.system(
        ("source %s && nvm version %s"):format(vim.fn.shellescape(nvm_dir .. "/nvm.sh"), vim.fn.shellescape(spec))
      )
    )
    if vim.v.shell_error == 0 then version = out:match "^v?(%d+%.%d+%.%d+)$" end
  end
  resolved[spec] = version or false
  return resolved[spec]
end

local function detect_current()
  for _, dir in ipairs(vim.split(vim.env.PATH or "", ":")) do
    local v = dir:match("^" .. vim.pesc(versions_dir) .. "/v(%d+%.%d+%.%d+)/bin$")
    if v then return v end
  end
end

--- Point Neovim's environment at the .nvmrc of `root` (project directory).
function M.apply(root)
  local spec = read_spec(root)
  if not spec then return end
  local version = resolve(spec)
  local bin = version and versions_dir .. "/v" .. version .. "/bin"
  if not version or vim.fn.isdirectory(bin) ~= 1 then
    vim.notify(
      ("nvm: .nvmrc needs node %s but it is not installed — run `nvm install %s`"):format(spec, spec),
      vim.log.levels.WARN
    )
    return
  end
  applied = applied or detect_current()
  if applied == version then return end

  local entries = { bin }
  for _, dir in ipairs(vim.split(vim.env.PATH, ":")) do
    if not dir:match(nvm_bin_pat) then entries[#entries + 1] = dir end
  end
  vim.env.PATH = table.concat(entries, ":")
  vim.env.NVM_BIN = bin
  vim.env.NVM_INC = versions_dir .. "/v" .. version .. "/include/node"
  applied = version
  vim.notify(("nvm: using node v%s (from .nvmrc)"):format(version), vim.log.levels.INFO)

  if #vim.lsp.get_clients() > 0 then vim.schedule(function() pcall(vim.cmd.LspRestart) end) end
end

--- Resolve the project root of a buffer (or explicit path) and apply its .nvmrc.
function M.sync(buf, path)
  if not path and buf and vim.api.nvim_buf_is_valid(buf) then path = vim.api.nvim_buf_get_name(buf) end
  if not path or path == "" then path = vim.uv.cwd() end
  local root = vim.fs.root(path, { ".nvmrc" })
  if root then M.apply(root) end
end

return M
