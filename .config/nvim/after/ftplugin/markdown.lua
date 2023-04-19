local opt, b, fn = vim.opt_local, vim.b, vim.fn

opt.spell = true

map('n', '<localleader>p', '<Plug>MarkdownPreviewToggle', { desc = 'markdown preview' })

b.formatting_disabled = not vim.startswith(fn.expand('%'), vim.env.PROJECTS_DIR .. '/personal')

as.ftplugin_conf({
  cmp = function(cmp)
    cmp.setup.filetype('markdown', {
      sources = {
        { name = 'dictionary', group_index = 1 },
        { name = 'spell', group_index = 1 },
        { name = 'emoji', group_index = 1 },
        { name = 'buffer', group_index = 2 },
      },
    })
  end,
  ['nvim-surround'] = function(surround)
    surround.buffer_setup({
      surrounds = {
        l = {
          add = function() return { { '[' }, { ('](%s)'):format(fn.getreg('*')) } } end,
        },
      },
    })
  end,
})
