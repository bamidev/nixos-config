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
use {
	"sainnhe/everforest",
	config = function()
		-- Pick the theme variant depending on the time of year
		local month = os.date("*t")["month"]
		local mode = "dark"
		if month >= 5 and month < 10 then
			mode = "light"
		end
		vim.o.background = mode
		vim.g.everforest_enable_italic = true
		vim.cmd.colorscheme("everforest")
	end
}
use {
	"lukas-reineke/indent-blankline.nvim",
	config = function()
		local highlight = {
			"CursorColumn",
			"Whitespace",
		}
		require("ibl").setup {
			indent = { highlight = highlight, char = "" },
			whitespace = {
				highlight = highlight,
				remove_blankline_trail = false,
			},
			scope = { enabled = false },
		}
	end
}
use "neovim/nvim-lspconfig"
use {
	"vim-airline/vim-airline",
	config = function()
		vim.g.airline_left_sep = ''
		vim.g.airline_left_alt_sep = ''
		vim.g.airline_right_sep = ''
		vim.g.airline_right_alt_sep = ''
		vim.g.airline_symbols.branch = ''
		vim.g.airline_symbols.readonly = ''
		vim.g.airline_symbols.linenr = ''
	end
}

