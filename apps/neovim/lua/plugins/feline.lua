return {
	"famiu/feline.nvim",
	tag = "v1.1.3",
	requires = {
		'ellisonleao/gruvbox.nvim',
		'uga-rosa/utf8.nvim',
	},
	config = function()
		if not vim.o.termguicolors then
			return
		end

		-- TODO: Get the colors frm the everforest palette when that colorscheme is used
		-- Colors can be found here: https://github.com/ellisonleao/gruvbox.nvim/blob/5e0a460d8e0f7f669c158dedd5f9ae2bcac31437/lua/gruvbox.lua#L75
		local palette = require('gruvbox').palette
		local my_theme = {
			bg = palette.light0,
			fg = palette.dark0_hard,

			bg2 = palette.dark1;
			bg3 = palette.dark2;
			bg4 = palette.dark3;

			black = palette.dark0_hard,
			blue = palette.neutral_blue,
			bright_blue = palette.bright_blue,
			cyan = palette.bright_aqua,
			dark_green = palette.dark_green,
			faded_blue = palette.faded_blue,
			faded_orange = palette.faded_orange,
			green = palette.neutral_green,
			gray = palette.dark4;
			magenta = palette.neutral_purple,
			oceanblue = palette.neutral_aqua,
			orange = palette.neutral_orange,
			red = palette.neutral_red,
			skyblue = palette.bright_blue,
			violet = palette.bright_purple,
			white = palette.light0_hard,
			yellow = palette.neutral_yellow,
		}

		require('feline').setup({
		  theme = my_theme,

		  left_sep = 'slant_left',
		  right_sep = 'slant_right',

		  components = require('plugins.feline.components'),
		})
	end,
}
