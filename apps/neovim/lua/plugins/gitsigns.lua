return {
	'lewis6991/gitsigns.nvim',
	tag = 'v1.0.2',
	config = function()
		local gitsigns = require('gitsigns')
		gitsigns.setup({
			on_attach = function()
				vim.keymap.set({'n', 'i'}, '<F10>', gitsigns.toggle_current_line_blame)
			end
		})
	end,
}
