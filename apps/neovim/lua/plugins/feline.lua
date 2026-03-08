return {
	"famiu/feline.nvim",
	tag = "v1.1.3",
	requires = {
		'ellisonleao/gruvbox.nvim',
		'sainnhe/everforest',
		'uga-rosa/utf8.nvim',
	},
	config = function()
		if not vim.o.termguicolors then
			return
		end

		-- TODO: Get the colors frm the everforest palette when that colorscheme is used
		-- Colors can be found here: https://github.com/ellisonleao/gruvbox.nvim/blob/5e0a460d8e0f7f669c158dedd5f9ae2bcac31437/lua/gruvbox.lua#L75
		local current_theme = vim.g.colors_name;
		local palette = {}
		local my_theme = {}
		if current_theme == 'gruvbox' then
			palette = require('gruvbox').palette
			my_theme = {
				bg = vim.o.background == 'light' and palette.light1 or palette.dark0,
				fg = vim.o.background == 'light' and palette.dark0 or palette.light0,

				bg2 = vim.o.background == 'light' and palette.light2 or palette.dark1;
				bg3 = vim.o.background == 'light' and palette.light3 or palette.dark2;
				bg4 = vim.o.background == 'light' and palette.light4 or palette.dark3;

				bg_aqua = palette.neutral_aqua,
				bg_blue = palette.neutral_blue,
				bg_gray = palette.dark4;
				bg_green = palette.neutral_green,
				bg_orange = palette.neutral_orange,
				bg_purple = palette.neutral_purple,
				bg_red = palette.neutral_red,
				bg_skyblue = palette.bright_blue,
				bg_bright_blue = palette.bright_blue,
				bg_dark_green = palette.dark_green,
				bg_faded_blue = palette.faded_blue,
				bg_faded_orange = palette.faded_orange,
				bg_yellow = palette.neutral_yellow,
				black = palette.dark0_hard,
				fg_blue = palette.neutral_blue,
				fg_cyan = palette.bright_aqua,
				fg_green = palette.neutral_green,
				fg_orange = palette.neutral_orange,
				fg_red = palette.neutral_red,
				fg_yellow = palette.neutral_yellow,
				white = palette.light0_hard,
			}
		else if current_theme == 'everforest' then
			-- Generate the palette in the same way it is done inside the plugin
			local config = vim.api.nvim_call_function('everforest#get_configuration', {})
			palette = vim.api.nvim_call_function('everforest#get_palette', {config.background, config.colors_override})
			my_theme = {
				bg = palette.bg1[1],
				fg = palette.fg[1],

				bg2 = palette.bg2[1];
				bg3 = palette.bg3[1];
				bg4 = palette.bg4[1];

				bg_aqua = palette.bg_blue[1],
				bg_bright_blue = palette.bg_blue[1],
				bg_cyan = palette.bg_blue[1],
				bg_dark_green = palette.bg_green[1],
				bg_faded_blue = palette.bg_blue[1],
				bg_faded_orange = palette.bg_red[1],
				bg_gray = palette.grey2[1],
				bg_green = palette.bg_green[1],
				bg_orange = palette.bg_yellow[1],
				bg_purple = '#463f48', -- bg_purple doesn't exist yet in v0.3.0
				bg_red = palette.bg_red[1],
				bg_skyblue = palette.bg_blue[1],
				bg_yellow = palette.bg_yellow[1],
				black = palette.bg_dim[1],
				bg_blue = palette.bg_blue[1],
				fg_blue = palette.blue[1],
				fg_green = palette.green[1],
				fg_orange = palette.orange[1],
				fg_red = palette.red[1],
				fg_yellow = palette.yellow[1],
				white = palette.grey0[1],
			}
		else
			print('Unknown theme: ' .. tostring(current_theme))
		end end
		require('feline').setup({
			theme = my_theme,
			left_sep = 'slant_left',
			right_sep = 'slant_right',
			components = require('plugins.feline.components'),
		})
	end,
}
