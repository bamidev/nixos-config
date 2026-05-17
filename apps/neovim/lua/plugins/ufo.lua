return {
	"kevinhwang91/nvim-ufo",
	--tag = "v1.5.0",
	-- Use a commit newer than v.1.5.0 to prevent the following bug:
	-- https://github.com/kevinhwang91/nvim-ufo/issues/309
	commit = "ab3eb124062422d276fae49e0dd63b3ad1062cfc",
	requires = {
		"kevinhwang91/promise-async",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		-- Settings required for the ufo plugin
		vim.o.foldcolumn = '1'
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true


		local ufo = require('ufo')
		ufo.setup({
			provider_selector = function(_, _, _)
				return {'treesitter', 'indent'}
			end,
			close_fold_kinds_for_ft = {
				cpp = {"class_specifier", "function_definition"},
				lua = {"function_declaration", "function_definition"},
				markdown = {"section"},
				python = {"class_definition", "function_definition", "imports"},
				rust = {"enum_item", "function_item", "impl_item", "struct_item", "use_declaration"},
			}
		})

		vim.keymap.set('n', '<C-a>', function()
			ufo.closeAllFolds()
			ufo.openFoldsExceptKinds()
		end)
	end
}
