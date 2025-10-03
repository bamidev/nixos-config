return {
	"famiu/feline.nvim",
	tag = "v1.1.3",
	requires = 'ellisonleao/gruvbox.nvim',
	config = function()
		if not vim.o.termguicolors then
			return
		end

		-- TODO: Get the colors frm the everforest palette when that colorscheme is used
		-- Colors can be found here: https://github.com/ellisonleao/gruvbox.nvim/blob/5e0a460d8e0f7f669c158dedd5f9ae2bcac31437/lua/gruvbox.lua#L75
		local palette = require('gruvbox').palette
		local my_theme = {
		  fg = palette.dark0_hard,
		  bg = palette.light0_hard,

		  black = palette.dark0_hard,
		  blue = palette.neutral_blue,
		  cyan = palette.gray,
		  green = palette.neutral_green,
		  magenta = palette.neutral_purple,
		  oceanblue = palette.neutral_aqua,
		  orange = palette.neutral_orange,
		  red = palette.neutral_red,
		  skyblue = palette.bright_blue,
		  violet = palette.bright_purple,
		  white = palette.light0_hard,
		  yellow = palette.neutral_yellow,
		}
		local feline = require('feline')
		feline.setup({
		  theme = my_theme,

		  left_sep = 'slant_left',
		  right_sep = 'slant_right',

		  components = {
			active = {
				-- Left
				{
					{
						provider = 'vi_mode',
						hl = function()
							return {
								name = require('feline.providers.vi_mode').get_mode_highlight_name(),
								fg = require('feline.providers.vi_mode').get_mode_color(),
								style = 'bold',
							}
						end,
						right_sep = ' ',
						icon = '',
					},
				},

				-- Middle
				{
					provider = 'file_info',
					hl = {
						fg = 'white',
						bg = 'oceanblue',
						style = 'bold'
					},
					left_sep = {' ', 'slant_left_2'},
					right_sep = {'slant_right_2', ' '},
				},

				-- Right
				{},
			},

			inactive = {

			},
		  }
		})
	end,
}
