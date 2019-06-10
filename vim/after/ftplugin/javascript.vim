setl completeopt-=preview
setlocal foldtext=utils#braces_fold_text()
setl colorcolumn=81

let b:switch_custom_definitions =
      \ [
      \   {
      \     '<div\(.\{-}\)>\(.\{-}\)</div>': '<span\1>\2</span>',
      \     '<span\(.\{-}\)>\(.\{-}\)</span>': '<div\1>\2</div>',
      \   }
      \ ]

function! JsEchoError(msg)
  redraw | echon 'js: ' | echohl ErrorMsg | echon a:msg | echohl None
endfunction

" Swapping between test file and main file.
function! JsSwitch(bang, cmd) abort
  let l:file = expand('%')
  if empty(l:file)
    call JsEchoError('no buffer name')
    return
  elseif l:file =~# '^\f\+.test\.js$'
    let l:root = split(l:file, '.test.js$')[0]
    let l:alt_file = l:root . '.js'
  elseif l:file =~# '^\f\+\.js$'
    let l:root = split(l:file, '.js$')[0]
    let l:alt_file = l:root . '.test.js'
  else
    call JsEchoError('not a js file')
    return
  endif
  if empty(a:cmd)
    execute ':edit ' . l:alt_file
  else
    execute ':' . a:cmd . ' ' . l:alt_file
  endif
endfunction

command! -bang A call JsSwitch(<bang>0, '')
let g:vim_jsx_pretty_colorful_config = 1
