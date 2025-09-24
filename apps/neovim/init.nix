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


  -- Map keys
  vim.keymap.set({'n', 'v', 'x'}, ';', ':')


  -- This piece of code used to be used to dynamically change the mode that diagnostic messages
  -- were shown. Now I have an addon (eagle) that I can use to show diagnotic info properly in
  -- small windows so I disabled the dynamic part of this.
  vim.api.nvim_create_autocmd({'BufWinEnter', 'VimResized'}, {
    callback = function(args)
      --local width = vim.api.nvim_win_get_width(0)
      local show_underneath = false
      vim.diagnostic.config({
        virtual_lines = show_underneath,
        virtual_text = not show_underneath,
      })
    end
  })


  require('plugins') -- Load all plugins
  require('lsp') -- Load all the LSP's
''
