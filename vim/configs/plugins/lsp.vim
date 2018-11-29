if exists('g:gui_oni')
  finish
endif
" \ 'reason': ['ocaml-language-server', '--stdio'],
let g:LanguageClient_serverCommands = {
    \ 'reason': ['~/reason-language-server/reason-language-server.exe', '--stdio'],
    \ 'ocaml': ['ocaml-language-server', '--stdio'],
    \ 'html': ['html-languageserver', '--stdio'],
    \ }
" \ 'javascript': ['flow-language-server', '--stdio'],
" \ 'javascript.jsx': ['flow-language-server', '--stdio'],

if executable('javascript-typescript-stdio')
  let g:LanguageClient_serverCommands.javascript = ['javascript-typescript-stdio']
  let g:LanguageClient_serverCommands["javascript.jsx"] = ['javascript-typescript-stdio']
  let g:LanguageClient_serverCommands.typescript = ['javascript-typescript-stdio']
  let g:LanguageClient_serverCommands["typescript.tsx"] = ['javascript-typescript-stdio']
endif

if executable('css-language-server')
  let g:LanguageClient_serverCommands.css = ['css-languageserver', '--stdio']
  let g:LanguageClient_serverCommands.sass = ['css-languageserver', '--stdio']
  let g:LanguageClient_serverCommands.scss = ['css-languageserver', '--stdio']
endif

if executable('flow-language-server')
  let g:LanguageClient_serverCommands.javascript = ['flow-language-server', '--stdio']
  let g:LanguageClient_serverCommands["javascript.jsx"] = ['flow-language-server', '--stdio']
endif

" Automatically start language servers.
let g:LanguageClient_autoStart = 1
" let g:LanguageClient_changeThrottle = 1.5

silent! nunmap gd
nnoremap <silent> <localleader>K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
nnoremap <silent> <localleader>ca :call LanguageClient_textDocument_codeAction()<CR>

set formatexpr=LanguageClient_textDocument_rangeFormatting()
