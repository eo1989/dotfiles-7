if not as then return end
local fn, fs, api = vim.fn, vim.fs, vim.api

----------------------------------------------------------------------------------------------------
--  Project root finder
----------------------------------------------------------------------------------------------------

local root_names = { '.git', 'Makefile', 'go.mod', 'go.sum' }
local ignored = { 'null-ls' }

-- Cache to use for speed up (at cost of possibly outdated results)
local root_cache = {}

---@param buf number
---@param ignore string[]
---@return string?
---@return string?
local function get_lsp_root(buf, ignore)
  local clients = vim.lsp.get_active_clients({ bufnr = buf })
  if not next(clients) then return end

  for _, client in pairs(clients) do
    local filetypes = client.config.filetypes
    if filetypes and vim.tbl_contains(filetypes, vim.bo[buf].ft) then
      if not vim.tbl_contains(ignore, client.name) then return client.config.root_dir, client.name end
    end
  end
end

---@param args AutocmdArgs
local function set_root(args)
  local path = api.nvim_buf_get_name(args.buf)
  if path == '' then return end
  path = fs.dirname(path)

  -- Try cache and resort to searching upward for root directory
  local root = root_cache[path]
  if not root then
    -- Currently this prefers marker files over the lsp root but swapping the order will change that
    local root_file = fs.find(root_names, {
      path = path,
      upward = true,
    })[1]

    root = fs.dirname(root_file) or get_lsp_root(args.buf, ignored)
  end
  if not root then return end
  root_cache[path] = root
  if root == fn.getcwd() then return end

  fn.chdir(root)
end

as.augroup('FindProjectRoot', { event = 'BufEnter', command = set_root })
