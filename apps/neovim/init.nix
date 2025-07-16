{ pkgs }: ''
  -- Default settings
  vim.o.autoindent = false
  vim.o.cindent = false
  vim.o.colorcolumn = "100"
  vim.o.number = true
  vim.o.shiftwidth = 4
  vim.o.smartindent = true
  vim.o.tabstop = 4
  vim.o.termguicolors = true
  vim.o.winborder = 'rounded'
  vim.opt.completeopt = { "fuzzy", "menuone", "noinsert", "popup" }
  vim.opt.list = true
  vim.opt.listchars = {eol = '↵', space = '·', tab = '┄┄'}


  -- Settings required for the ufo plugin
  vim.o.foldcolumn = '1'
  vim.o.foldlevel = 99
  vim.o.foldlevelstart = 99
  vim.o.foldenable = true


  vim.diagnostic.config({
    --virtual_lines = true,
    virtual_text = true,
  })

  -- Map keys
  vim.keymap.set({'n', 'v', 'x'}, ';', ':')


  require('plugins') -- Load all plugins
  require('lsp')
''
