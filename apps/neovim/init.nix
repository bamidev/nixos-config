{ pkgs }: ''
  vim.o.termguicolors = os.getenv("COLORTERM") == "24bit" or os.getenv("COLORTERM") == "truecolor"

  -- Default settings
  vim.o.number = true
  vim.o.winborder = 'rounded'

  vim.opt.autoindent = false
  vim.opt.cindent = false
  vim.opt.colorcolumn = "100"
  vim.opt.shiftwidth = 4
  vim.opt.smartindent = true
  vim.opt.tabstop = 4
  vim.opt.clipboard:append('unnamedplus')
  vim.opt.completeopt = { "fuzzy", "menuone", "noinsert", "popup" }
  vim.opt.list = vim.o.termguicolors
  vim.opt.listchars = {eol = '↵', space = '·', tab = '┄┄'}

  vim.diagnostic.config({
    virtual_lines = false,
    virtual_text = true,
  })

  -- Map keys
  vim.keymap.set({'n', 'v', 'x'}, ';', ':')


  -- Load everything else
  require('plugins') -- Load all plugins
  require('lsp') -- Load all the LSP's
''
