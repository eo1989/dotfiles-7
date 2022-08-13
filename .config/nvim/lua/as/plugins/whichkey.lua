return function()
  require('as.highlights').plugin('whichkey', { { WhichkeyFloat = { link = 'NormalFloat' } } })

  local wk = require('which-key')
  wk.setup({
    plugins = {
      spelling = {
        enabled = true,
      },
    },
    window = {
      border = as.style.current.border,
    },
    layout = {
      align = 'center',
    },
  })

  wk.register({
    ['<space><space>'] = 'toggle fold under cursor',
    [']'] = {
      name = '+next',
      ['<space>'] = 'add space below',
    },
    ['['] = {
      name = '+prev',
      ['<space>'] = 'add space above',
    },
    ['g>'] = 'show message history',
    ['<leader>'] = {
      c = { name = '+code-action' },
      d = {
        name = '+treesitter: peek',
        f = 'treesitter: peek function definition',
        F = 'treesitter: peek class definition',
      },
      n = {
        name = '+new',
        f = 'create a new file',
        s = 'create new file in a split',
      },
      E = 'show token under the cursor',
      p = {
        name = '+packer',
        c = 'clean',
        s = 'sync',
      },
      q = {
        name = '+quit',
        w = 'close window (and buffer)',
        q = 'delete buffer',
      },
      g = 'grep word under the cursor',
      l = {
        name = '+list',
        i = 'toggle location list',
        s = 'toggle quickfix',
      },
      i = { name = '+iswap' },
      e = {
        name = '+edit',
        v = 'open vimrc in a vertical split',
        p = 'open plugins file in a vertical split',
        z = 'open zshrc in a vertical split',
        t = 'open tmux config in a vertical split',
      },
      r = { name = '+lsp-refactor' },
      o = {
        name = '+only',
        n = 'close all other buffers',
      },
      t = {
        name = '+tab',
        c = 'tab close',
        n = 'tab edit current buffer',
      },
      s = {
        name = '+source/swap',
        w = 'swap buffers horizontally',
        o = 'source current buffer',
        v = 'source init.vim',
      },
      y = { name = '+yank' },
      U = 'uppercase all word',
      ['<CR>'] = 'repeat previous macro',
      [','] = 'go to previous buffer',
      ['='] = 'make windows equal size',
      [')'] = 'wrap with parens',
      ['}'] = 'wrap with braces',
      ['"'] = 'wrap with double quotes',
      ["'"] = 'wrap with single quotes',
      ['`'] = 'wrap with back ticks',
      ['['] = 'replace cursor word in file',
      [']'] = 'replace cursor word in line',
    },
    ['<localleader>'] = {
      name = 'local leader',
      n = { name = '+neogen' },
      o = { name = '+neorg' },
      t = { name = '+neotest' },
      w = {
        name = '+window',
        h = 'change two vertically split windows to horizontal splits',
        v = 'change two horizontally split windows to vertical splits',
        x = 'swap current window with the next',
        j = 'resize: downwards',
        k = 'resize: upwards',
      },
      l = 'redraw window',
      z = 'center view port',
      [','] = 'add comma to end of line',
      [';'] = 'add semicolon to end of line',
      ['?'] = 'search for word under cursor in google',
      ['!'] = 'search for word under cursor in google',
      ['['] = 'abolish = subsitute cursor word in file',
      [']'] = 'abolish = substitute cursor word on line',
      ['/'] = 'find matching word in buffer',
      ['<tab>'] = 'open commandline bufferlist',
    },
  })
end
