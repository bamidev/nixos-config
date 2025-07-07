-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"



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
require("lazy").setup({
  spec = {
	{
		"morhetz/gruvbox",
		commit = "697c00291db857ca0af00ec154e5bd514a79191f",
		pin = true,
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
	},
	{
		"nvim-treesitter/nvim-treesitter",
		commit = "42fc28ba918343ebfd5565147a42a26580579482",
		pin = true,
		config = function()
			require('nvim-treesitter.configs').setup {
				ensure_installed = {
					"c", "cpp", "lua", "markdown", "markdown_inline", "nix", "python", "rust", "vim", "vimdoc", "query"
				},

				auto_install = true,
				sync_install = false,

				highlight = {
					enable = true,
				},
			}
		end
	},
	{
		"preservim/nerdtree",
		commit = "9b465acb2745beb988eff3c1e4aa75f349738230",
		pin = true,
		config = function()
			vim.keymap.set({'n', 'v', 'x'}, '<C-t>', ':NERDTreeToggle<cr>')
			vim.keymap.set({'n', 'v', 'x'}, '<C-f>', ':NERDTreeFind<cr>')
		end
	},
	{
		"sainnhe/everforest",
		commit = "f40c2e6c8784c99c57c79edc94cd180e76450222",
		pin = true,
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
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		commit = "005b56001b2cb30bfa61b7986bc50657816ba4ba",
		pin = true,
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
	},
	{
		"vim-airline/vim-airline",
		pin = "6bba673aa8993eceec233be17b42ddfb9540794b",
		pin = true,
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
	},
	{
		"kevinhwang91/nvim-ufo",
		pin = "80fe8215ba566df2fbf3bf4d25f59ff8f41bc0e1",
		pin = true,
		requires = "kevinhwang91/promise-async",
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
	},
	{
		"kevinhwang91/promise-async",
		pin = true,
		commit = "119e8961014c9bfaf1487bf3c2a393d254f337e2",
	}
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  --install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = false },
})
