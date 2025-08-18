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
  vim.o.virtualedit = 'all'
  vim.o.winborder = 'rounded'
  vim.opt.completeopt = { "fuzzy", "menuone", "noinsert", "popup" }
  vim.opt.list = true
  vim.opt.listchars = {eol = '↵', space = '·', tab = '┄┄'}


  -- Settings required for the ufo plugin
  vim.o.foldcolumn = '1'
  vim.o.foldlevel = 99
  vim.o.foldlevelstart = 99
  vim.o.foldenable = true


  -- Map keys
  vim.keymap.set({'n', 'v', 'x'}, ';', ':')


  -- Put diagnostic messages under the line of code if the window is not wide enough to show it
  -- properly.
  vim.api.nvim_create_autocmd({'BufWinEnter', 'VimResized'}, {
    callback = function(args)
      local width = vim.api.nvim_win_get_width(0)
      local is_small = width <= (vim.o.textwidth + 20)
      vim.diagnostic.config({
        virtual_lines = is_small,
        virtual_text = not is_small,
      })
    end
  })


  require('plugins') -- Load all plugins
  require('lsp')


''
