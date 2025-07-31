-- Bootstrap pckr.nvim
local function bootstrap_pckr()
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"

  if not (vim.uv or vim.loop).fs_stat(pckr_path) then
    vim.fn.system({
      'git',
      'clone',
      "--filter=blob:none",
      'https://github.com/lewis6991/pckr.nvim',
      pckr_path
    })

    -- Pin pckr to a specific commit
    vim.fn.system({
      'git',
	  'reset',
	  '--hard',
	  'dcc0e2766d7a3a1911287fef7060ac07908cf376'
    })
  end

  vim.opt.rtp:prepend(pckr_path)
end

bootstrap_pckr()


-- Pick the theme variant depending on the time of year
local season = "winter"
local month = os.date("*t")["month"]
if month >= 4 and month <= 6 then
	season = "spring"
else if month >= 7 and month <= 9 then
	season = "summer"
else if month >= 10 and month <= 12 then
	season = "fall"
end end end


-- Plugins
require('pckr').add{
	{
		"lukas-reineke/indent-blankline.nvim",
		tag = "v3.9.0",
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
		"morhetz/gruvbox",
		tag = "v3.0.1-rc.0",
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
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			local builtin = require('telescope.builtin')
			vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
			vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
			vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
			vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
		end
	},
	{
		"nvim-treesitter/nvim-treesitter",
		tag = "v0.10.0",
		config = function()
			require('nvim-treesitter.configs').setup {
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
		tag = "7.1.3",
		config = function()
			vim.keymap.set({'n', 'v', 'x'}, '<C-t>', ':NERDTreeToggle<cr>')
			vim.keymap.set({'n', 'v', 'x'}, '<C-f>', ':NERDTreeFind<cr>')
		end
	},
	{
		"sainnhe/everforest",
		tag = "v0.3.0",
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
		"vim-airline/vim-airline",
		tag = "v0.11",
		config = function()
			-- The gruvbox theme doesn't work well with airline
			if vim.g.colors_name ~= "gruvbox" then
				vim.g.airline_left_sep = ''
				vim.g.airline_left_alt_sep = ''
				vim.g.airline_right_sep = ''
				vim.g.airline_right_alt_sep = ''
				--vim.g.airline_symbols.branch = ''
				--vim.g.airline_symbols.readonly = ''
				--vim.g.airline_symbols.linenr = ''
			end
		end
	},
	{
		"kevinhwang91/nvim-ufo",
		tag = "v1.5.0",
		requires = "kevinhwang91/promise-async",
		config = function()
			require('ufo').setup({
				provider_selector = function(_, _, _)
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
}
