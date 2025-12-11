return {
	"kevinhwang91/nvim-ufo",
	--tag = "v1.5.0",
	-- Revert to the last known working commit to prevent the following bug:
	-- https://github.com/kevinhwang91/nvim-ufo/issues/309
	commit = "5b75cf5fdb74054fc8badb2e7ca9911dc0470d94",
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
