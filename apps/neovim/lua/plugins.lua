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
user.setup { parallel = false }
local use = user.use


-- Pick the theme variant depending on the time of year
local season = "winter"
local month = os.date("*t")["month"]
if month >= 4 and month <= 6 then
	season = "spring"
else if month >= 7 and month <= 9 then
	season = "summer"
else if month >= 9 and month <= 11 then
	season = "fall"
end end end


-- Plugins
use {
	"morhetz/gruvbox",
	pin = "697c00291db857ca0af00ec154e5bd514a79191f",
	config = function()
		if season == "fall" then
			vim.o.background = "dark"
		else if season == "spring" then
			vim.o.background = "light"
		else
			return
		end end
		vim.cmd.colorscheme("gruvbox")
		--vim.g.airline_theme = 'gruvbox'
	end
}
use {
	"nvim-treesitter/nvim-treesitter",
	pin = "42fc28ba918343ebfd5565147a42a26580579482",
	config = function()
		require('nvim-treesitter.configs').setup {
			ensure_installed = {
				"c", "cpp", "lua", "markdown", "markdown_inline", "nix", "python", "vim", "vimdoc", "query"
			},

			auto_install = true,
			sync_install = false,

			highlight = {
				enable = true,
			},
		}
	end
}
use {
  "preservim/nerdtree",
  pin = "9b465acb2745beb988eff3c1e4aa75f349738230",
  config = function()
    vim.keymap.set({'n', 'v', 'x'}, '<C-t>', ':NERDTreeToggle<cr>')
    vim.keymap.set({'n', 'v', 'x'}, '<C-f>', ':NERDTreeFind<cr>')
  end
}
use {
	"sainnhe/everforest",
	pin = "f40c2e6c8784c99c57c79edc94cd180e76450222",
	config = function()
		if season == "winter" then
			vim.o.background = "dark"
		else if season == "summer" then
			vim.o.background = "light"
		else
			return
		end end
		vim.g.everforest_enable_italic = true
		vim.cmd.colorscheme("everforest")
	end
}
use {
	"lukas-reineke/indent-blankline.nvim",
	pin = "005b56001b2cb30bfa61b7986bc50657816ba4ba",
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
use {
	"vim-airline/vim-airline",
	pin = "6bba673aa8993eceec233be17b42ddfb9540794b",
	config = function()
		-- The gruvbox theme doesn't work well with airline
		if vim.g.colors_name ~= "gruvbox" then
			vim.g.airline_left_sep = ''
			vim.g.airline_left_alt_sep = ''
			vim.g.airline_right_sep = ''
			vim.g.airline_right_alt_sep = ''
			vim.g.airline_symbols.branch = ''
			vim.g.airline_symbols.readonly = ''
			vim.g.airline_symbols.linenr = ''
		end
	end
}
use {
	"kevinhwang91/promise-async",
	pin = "119e8961014c9bfaf1487bf3c2a393d254f337e2"
}
use {
	"kevinhwang91/nvim-ufo",
	pin = "80fe8215ba566df2fbf3bf4d25f59ff8f41bc0e1",
	config = function()
		require('ufo').setup({
			provider_selector = function(bufnr, filetype, buftype)
				return {'treesitter', 'indent'}
			end,
			close_fold_kinds_for_ft = {
				default = {"function_definition", "imports"},
				python = {"class_definition", "function_definition", "imports"},
				cpp = {"class_specifier", "function_definition"},
				rust = {"function_item", "impl_item", "struct_item", "use_declaration"},
			}
		})
	end
}


user.flush()
user.clean()
