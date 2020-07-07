if !PluginLoaded("nvim-tree.lua")
  finish
endif

let g:lua_tree_icons = {
    \ 'default': '',
    \ 'git': {
    \   'unstaged': "",
    \   'staged': "",
    \   'unmerged': "",
    \   'renamed': "",
    \   'untracked': ""
    \   },
    \ 'folder': {
    \   'default': "",
    \   'open': ""
    \   }
    \ }

let g:lua_tree_bindings = {
    \ 'cd': '<BS>',
    \}

let g:lua_tree_indent_markers = 1
nnoremap <silent><c-n> :LuaTreeToggle<CR>
let g:lua_tree_auto_close = 1 " 0 by default, closes the tree when it's the last window
let g:lua_tree_follow     = 0 " On bufEnter find the current file
let g:lua_tree_bindings = {
      \ "edit": "o",
      \}
let g:lua_tree_ignore = [ '.git', 'node_modules' ]
let g:lua_tree_size = &columns * 0.33 " Make lua tree proportional in size


let comment_fg = synIDattr(hlID('Comment'), 'fg')

execute 'highlight LuaTreeIndentMarker guifg=' . comment_fg

augroup LuaTreeOverrides
  autocmd!
  autocmd FileType LuaTree setlocal nowrap
  " FIXME this shouldn't be necessary technically but nvim-tree.lua does not
  " pick up the correct statusline otherwise
  autocmd FileType LuaTree setlocal statusline=%!MinimalStatusLine()
augroup END
