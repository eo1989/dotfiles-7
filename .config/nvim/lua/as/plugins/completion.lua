local function config()
  local cmp = require('cmp')

  local fmt = string.format
  local border = as.style.current.border
  local lsp_hls = as.style.lsp.highlights
  local ellipsis = as.style.icons.misc.ellipsis
  local luasnip = require('luasnip')

  local kind_hls = as.fold(
    function(accum, value, key)
      accum[#accum + 1] = { ['CmpItemKind' .. key] = { foreground = { from = value } } }
      return accum
    end,
    lsp_hls,
    {
      { CmpItemAbbr = { foreground = 'fg', background = 'NONE', italic = false, bold = false } },
      { CmpItemAbbrMatch = { foreground = { from = 'Keyword' } } },
      { CmpItemAbbrDeprecated = { strikethrough = true, inherit = 'Comment' } },
      { CmpItemAbbrMatchFuzzy = { italic = true, foreground = { from = 'Keyword' } } },
      -- Make the source information less prominent
      {
        CmpItemMenu = {
          fg = { from = 'Pmenu', attr = 'bg', alter = 30 },
          italic = true,
          bold = false,
        },
      },
    }
  )

  as.highlight.plugin('Cmp', kind_hls)

  local function tab(fallback)
    if cmp.visible() then
      cmp.select_next_item()
    elseif luasnip.expand_or_locally_jumpable() then
      luasnip.expand_or_jump()
    else
      fallback()
    end
  end

  local function shift_tab(fallback)
    if cmp.visible() then
      cmp.select_prev_item()
    elseif luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      fallback()
    end
  end

  local cmp_window = {
    border = border,
    winhighlight = table.concat({
      'Normal:NormalFloat',
      'FloatBorder:FloatBorder',
      'CursorLine:Visual',
      'Search:None',
    }, ','),
  }
  cmp.setup({
    experimental = { ghost_text = false },
    matching = {
      disallow_partial_fuzzy_matching = false,
    },
    window = {
      completion = cmp.config.window.bordered(cmp_window),
      documentation = cmp.config.window.bordered(cmp_window),
    },
    snippet = {
      expand = function(args) require('luasnip').lsp_expand(args.body) end,
    },
    mapping = {
      ['<Tab>'] = cmp.mapping(tab, { 'i', 's', 'c' }),
      ['<S-Tab>'] = cmp.mapping(shift_tab, { 'i', 's', 'c' }),
      ['<C-q>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }), -- If nothing is selected don't complete
    },
    formatting = {
      deprecated = true,
      fields = { 'abbr', 'kind', 'menu' },
      format = function(entry, vim_item)
        local MAX = math.floor(vim.o.columns * 0.5)
        if #vim_item.abbr >= MAX then vim_item.abbr = vim_item.abbr:sub(1, MAX) .. ellipsis end
        vim_item.kind = fmt('%s %s', as.style.current.lsp_icons[vim_item.kind], vim_item.kind)
        vim_item.menu = ({
          nvim_lsp = '[LSP]',
          nvim_lua = '[Lua]',
          emoji = '[E]',
          path = '[Path]',
          neorg = '[N]',
          luasnip = '[SN]',
          dictionary = '[D]',
          buffer = '[B]',
          spell = '[SP]',
          cmdline = '[Cmd]',
          cmdline_history = '[Hist]',
          orgmode = '[Org]',
          norg = '[Norg]',
          rg = '[Rg]',
          git = '[Git]',
        })[entry.source.name]
        return vim_item
      end,
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
      {
        name = 'rg',
        keyword_length = 4,
        max_item_count = 10,
        option = { additional_arguments = '--max-depth 8' },
      },
    }, {
      {
        name = 'buffer',
        options = {
          get_bufnrs = function() return vim.api.nvim_list_bufs() end,
        },
      },
      { name = 'spell' },
    }),
  })

  if not as.nightly() then
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        sources = cmp.config.sources(
          { { name = 'nvim_lsp_document_symbol' } },
          { { name = 'buffer' } }
        ),
      },
    })

    cmp.setup.cmdline(':', {
      sources = cmp.config.sources({
        { name = 'cmdline', keyword_pattern = [=[[^[:blank:]\!]*]=] },
        { name = 'path' },
        { name = 'cmdline_history', priority = 10, max_item_count = 5 },
      }),
    })
  end

  require('cmp').setup.filetype({ 'dap-repl', 'dapui_watches' }, {
    sources = { { name = 'dap' } },
  })
end

return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    config = config,
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-cmdline', enabled = not as.nightly() },
      { 'dmitmel/cmp-cmdline-history', enabled = not as.nightly() },
      { 'hrsh7th/cmp-nvim-lsp-document-symbol', enabled = not as.nightly() },
      { 'f3fora/cmp-spell' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-emoji' },
      { 'rcarriga/cmp-dap' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'lukas-reineke/cmp-rg' },
      {
        'petertriho/cmp-git',
        opts = { filetypes = { 'gitcommit', 'NeogitCommitMessage' } },
      },
      -- Use <Tab> to escape from pairs such as ""|''|() etc.
      { 'abecodes/tabout.nvim', opts = { ignore_beginning = false, completion = false } },
    },
  },
}
