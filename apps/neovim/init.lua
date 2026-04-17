vim.o.termguicolors = os.getenv("COLORTERM") == "24bit" or os.getenv("COLORTERM") == "truecolor"

-- Default settings
vim.o.number = true
vim.o.signcolumn = "yes"
vim.o.winborder = 'rounded'

vim.opt.autoindent = false
vim.opt.cindent = false
vim.opt.shiftwidth = 4
vim.opt.smartindent = false
vim.opt.tabstop = 4
vim.opt.clipboard:append('unnamedplus')
vim.opt.completeopt = { "fuzzy", "menuone", "noinsert", "popup" }
vim.opt.list = vim.o.termguicolors
vim.opt.listchars = {eol = '↵', space = '·', tab = '┄┄'}

vim.diagnostic.config({
  virtual_lines = false,
  virtual_text = true,
})

-- Load everything else
require('commands')
require('map')
require('plugins') -- Load all plugins
require('lsp') -- Load all the LSP's
