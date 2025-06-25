-- Default settings
vim.o.autoindent = false
vim.o.cindent = false
vim.o.number = true
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.tabstop = 4
vim.o.termguicolors = true
vim.o.winborder = 'rounded'
vim.opt.completeopt = { "fuzzy", "menuone", "noinsert", "popup" }
vim.opt.list = true
vim.opt.listchars = {eol = '↵', space = '·', tab = '>~'}


vim.diagnostic.config({
	virtual_lines = true,
	--virtual_text = true,
})

-- Autocomplete

-- Map keys
vim.keymap.set('n', ';', ':')
vim.keymap.set('v', ';', ':')
vim.keymap.set('x', ';', ':')


-- Bootstrap and set up user.nvim
local user_packadd_path = "faerryn_user.nvim/default/default/default/default"
local user_install_path = vim.fn.stdpath "data" .. "/site/pack/user/opt/" .. user_packadd_path
if vim.fn.isdirectory(user_install_path) == 0 then
    os.execute(
        "git clone --quiet --depth 1 https://github.com/faerryn/user.nvim.git " .. vim.fn.shellescape(user_install_path)
    )
end
vim.api.nvim_command("packadd " .. vim.fn.fnameescape(user_packadd_path))
local user = require "user"
user.setup()
local use = user.use


-- Plugin list
use "neovim/nvim-lspconfig"
use "vim-airline/vim-airline"
use "kevinhwang91/promise-async"
use "kevinhwang91/nvim-ufo"
