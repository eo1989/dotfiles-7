---@diagnostic disable: duplicate-doc-param

if not as.ui.winbar.enable then return end

local highlights = require('as.highlights')
local utils = require('as.utils.statusline')

local fn, api = vim.fn, vim.api
local component = utils.component
local component_raw = utils.component_raw
local empty = as.empty
local icons = as.style.icons.misc

local dir_separator = '/'
local separator = icons.arrow_right
local ellipsis = icons.ellipsis

--- A mapping of each winbar items ID to its path
--- @type table<string, string>
as.ui.winbar.state = {}

---@param id number
---@param _ number number of clicks
---@param _ "l"|"r"|"m" the button clicked
---@param _ string modifiers
function as.ui.winbar.click(id, _, _, _)
  if id then vim.cmd.edit(as.ui.winbar.state[id]) end
end

highlights.plugin('winbar', {
  { Winbar = { bold = false } },
  { WinbarNC = { bold = false } },
  { WinbarCrumb = { bold = true } },
  { WinbarIcon = { inherit = 'Function' } },
  { WinbarDirectory = { inherit = 'Directory' } },
})

local function breadcrumbs()
  local ok, navic = pcall(require, 'nvim-navic')
  local empty_state = { component(ellipsis, 'NonText', { priority = 0 }) }
  if not ok or not navic.is_available() then return empty_state end
  local navic_ok, location = pcall(navic.get_location)
  if not navic_ok or empty(location) then return empty_state end
  local win = api.nvim_get_current_win()
  return { component_raw(location, { priority = 1, win_id = win, type = 'winbar' }) }
end

---@return string
function as.ui.winbar.get()
  local winbar = {}
  local add = utils.winline(winbar)

  add(utils.spacer(1))

  local bufname = api.nvim_buf_get_name(api.nvim_get_current_buf())
  if empty(bufname) then return add(component('[No name]', 'Winbar', { priority = 0 })) end

  local parts = vim.split(fn.fnamemodify(bufname, ':.'), '/')

  as.foreach(function(part, index)
    local priority = (#parts - (index - 1)) * 2
    local is_last = index == #parts
    local sep = is_last and separator or dir_separator
    local hl = is_last and 'Winbar' or 'NonText'
    local suffix_hl = is_last and 'WinbarDirectory' or 'NonText'
    as.ui.winbar.state[priority] = table.concat(vim.list_slice(parts, 1, index), '/')
    add(component(part, hl, {
      id = priority,
      priority = priority,
      click = 'v:lua.as.ui.winbar.click',
      suffix = sep,
      suffix_color = suffix_hl,
    }))
  end, parts)
  add(unpack(breadcrumbs()))
  return utils.display(winbar, api.nvim_win_get_width(api.nvim_get_current_win()))
end

local blocked = {
  'NeogitStatus',
  'DiffviewFiles',
  'NeogitCommitMessage',
  'toggleterm',
  'DressingInput',
  'org',
}

local allowed = {
  'toggleterm',
  'neo-tree',
}

local function set_winbar()
  as.foreach(function(win)
    local buf = api.nvim_win_get_buf(win)
    local ft, bt = vim.bo[buf].filetype, vim.bo[buf].buftype
    local is_diff = vim.wo[win].diff
    if
      not vim.tbl_contains(blocked, ft)
      and fn.win_gettype(win) == ''
      and bt == ''
      and ft ~= ''
      and not is_diff
    then
      vim.wo[win].winbar = '%{%v:lua.as.ui.winbar.get()%}'
    elseif is_diff or not vim.tbl_contains(allowed, ft) then
      vim.wo[win].winbar = nil
    end
  end, api.nvim_tabpage_list_wins(0))
end

as.augroup('AttachWinbar', {
  {
    event = { 'BufWinEnter', 'TabNew', 'TabEnter', 'BufEnter', 'WinClosed' },
    desc = 'Toggle winbar',
    command = set_winbar,
  },
  {
    event = 'User',
    pattern = { 'DiffviewDiffBufRead', 'DiffviewDiffBufWinEnter' },
    desc = 'Toggle winbar',
    command = set_winbar,
  },
})
