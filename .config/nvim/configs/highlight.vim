""---------------------------------------------------------------------------//
" Highlights
""---------------------------------------------------------------------------//

"--------------------------------------------------------------------------------
" Plugin highlights
"--------------------------------------------------------------------------------
function! s:plugin_highlights() abort
  if PluginLoaded('vim-sneak')
    " Highlighting sneak and it's label is a little complicated
    " The plugin creates a colorscheme autocommand that
    " checks for the existence of these highlight groups
    " it is best to leave this as is as they are picked up on colorscheme loading
    highlight Sneak guifg=red guibg=background
    highlight SneakLabel gui=italic,bold,underline guifg=red guibg=background
    highlight SneakLabelMask guifg=red guibg=background
  endif

  if PluginLoaded('vim-which-key')
    highlight WhichKeySeperator guifg=green guibg=background
  endif

  if !PluginLoaded('conflict-marker.vim')
    " Highlight VCS conflict markers
    match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'
  endif
endfunction

function! s:general_overrides() abort
  " Add undercurl to existing spellbad highlight
  let s:error_fg = synIDattr(hlID('Error'), 'fg')
  let s:rare_fg = synIDattr(hlID('SpellRare'), 'fg')
  execute 'highlight SpellBad gui=underline guibg=transparent guifg=transparent guisp='.s:error_fg

  " Define highlight for URIs e.g. http://stackoverflow.com
  " this is used in the syntax after files for highlighting URIs in comments
  let s:comment_fg = synIDattr(hlID('Comment'), 'fg')
  execute 'highlight URIHighlight guisp='.s:comment_fg.' gui=underline,italic guifg='.s:comment_fg

  highlight Todo gui=bold
  highlight Credit gui=bold
  highlight CursorLineNr guifg=yellow gui=bold
  highlight FoldColumn guibg=background
  highlight! link dartStorageClass Statement

  " Customize Diff highlighting
  highlight DiffAdd guibg=green guifg=NONE
  highlight DiffDelete guibg=red guifg=#5c6370

  " NOTE: these highlights are used by fugitive's Git buffer
  " highlight! link DiffAdded DiffAdd
  " highlight! link DiffRemoved DiffDelete
  highlight DiffChange guibg=#344f69 guifg=NONE
  highlight DiffText guibg=#2f628e guifg=NONE
endfunction

""---------------------------------------------------------------------------//
" Colorscheme highlights
""---------------------------------------------------------------------------//
function! s:colorscheme_overrides() abort
  if g:colors_name ==? 'one'
    call one#highlight('Folded', '5c6370', 'none', 'italic,bold')
    call one#highlight('Type', 'e5c07b', 'none', 'italic,bold')
    " Italicise imports
    call one#highlight('jsxComponentName', '61afef', 'none', 'bold,italic')
    call one#highlight('Include', '61afef', 'none', 'italic')
    call one#highlight('jsImport', '61afef', 'none', 'italic')
    call one#highlight('jsExport', '61afef', 'none', 'italic')
    call one#highlight('typescriptImport', 'c678dd', 'none', 'italic')
    call one#highlight('typescriptExport', '61afef', 'none', 'italic')
    call one#highlight('vimCommentTitle', 'c678dd', 'none', 'bold,italic')
  elseif g:colors_name ==? 'onedark'
    " Do nothing overrides have been done elsewhere
  elseif g:colors_name ==? 'vim-monokai-tasty'
    highlight clear SignColumn
    highlight GitGutterAdd guifg=green
    highlight GitGutterChange guifg=yellow
    highlight GitGutterDelete guifg=red
    " Italicise imports and exports without breaking their base highlights
    call utils#extend_highlight('Special', 'SpecialItalic', 'gui=italic')
    highlight link typescriptImport SpecialItalic
    highlight link typescriptExport SpecialItalic
    highlight link jsxAttrib SpecialItalic
    highlight tsxAttrib gui=italic,bold
  else " No specific colour scheme with overrides then do it manually
    highlight jsFuncCall gui=italic
    highlight Comment gui=italic cterm=italic
    highlight xmlAttrib gui=italic,bold cterm=italic,bold ctermfg=121
    highlight jsxAttrib cterm=italic,bold ctermfg=121
    highlight Type    gui=italic,bold cterm=italic,bold
    highlight jsThis ctermfg=224,gui=italic
    highlight Include gui=italic cterm=italic
    highlight jsFuncArgs gui=italic cterm=italic ctermfg=217
    highlight jsClassProperty ctermfg=14 cterm=bold,italic term=bold,italic
    highlight jsExportDefault gui=italic,bold cterm=italic ctermfg=179
    highlight htmlArg gui=italic,bold cterm=italic,bold ctermfg=yellow
    highlight Folded  gui=bold,italic cterm=bold
    highlight link typescriptExport jsImport
    highlight link typescriptImport jsImport
  endif
endfunction

function! s:apply_user_highlights() abort
  if has('nvim')
    highlight TermCursor ctermfg=green guifg=green
    highlight link MsgSeparator Comment
  endif
  call s:plugin_highlights()
  call s:general_overrides()
  call s:colorscheme_overrides()
endfunction


augroup InitHighlights
  au!
  autocmd VimEnter * call s:apply_user_highlights()
  autocmd ColorScheme * call s:apply_user_highlights()
augroup END
