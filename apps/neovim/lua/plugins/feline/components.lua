local git = require('utils.git')
local vi_mode = require('feline.providers.vi_mode')
local utf8 = require('utf8')


local function component(provider, color, side, neighbour, sep_left, sep_right, options)
	local function generate_sep_table(color_, sep_side)
		local table = {
			str = utf8.char(0x2588),
			hl = {
				bg = color_,
			},
			always_visible = true
		}
		if provider == '' then
			table.str = ''
		else if type(provider) == "function" then
			-- This does make the provider function get executed twice, but I see no other way for
			-- the moment...
			local value = provider()
			if value == '' then
				table.str = ''
			end
		end end

		-- Set the background color of the seperator to match the neighbour's backgound color
		if neighbour ~= nil then
			table.hl.fg = neighbour.hl.fg
		end

		-- Change the seperator depending on which side the component is placed
		if side ~= 'left' and sep_side == 'left' then
			table.str = (sep_left or utf8.char(0xE0B2)) .. table.str
		end
		if side ~= 'right' and sep_side == 'right' then
			table.str = table.str .. (sep_right or utf8.char(0xE0B0))
		end
		return table
	end

	local hl_base = nil
	local sep_table_left = nil
	local sep_table_right = nil
	if type(color) == "function" then
		hl_base = function()
			return {
				fg = color()
			}
		end
		sep_table_left = function()
			return generate_sep_table(color(), 'left')
		end
		sep_table_right = function()
			return generate_sep_table(color(), 'right')
		end
	else
		hl_base = { fg = color }
		sep_table_left = generate_sep_table(color, 'left')
		sep_table_right = generate_sep_table(color, 'right')
	end

	local c = {
		provider = provider,
		update = {'BufEnter'},
		hl = hl_base,
		left_sep = sep_table_left,
		right_sep = sep_table_right,
		icon = ''
	}
	if options ~= nil then
		for k, v in pairs(options) do c[k] = v end
	end

	return c
end


local file_encoding_component = component('file_encoding', 'skyblue', 'right')

local file_type_component = component(
	function()
		return vim.bo.filetype:gsub("^%l", string.upper) or ''
	end,
	function()
		local table = {
			lua = 'blue',
			python = 'yellow',
			nix = 'faded_blue',
			rust = 'orange',
			xml = 'bright_blue',
		}

		local color = table[vim.bo.filetype]
		if color ~= nil then
			return color
		end
		return "grey"
	end,
	'right',
	file_encoding_component
)

local git_branch_component = component(function()
	return git.get_branch() or ''
end, 'oceanblue', 'left')

local vi_mode_component = component('vi_mode', function()
	return vi_mode.get_mode_color()
end, 'left', git_branch_component)

local file_info_component = component(
	{
		name = 'file_info',
		opts = {
			colored_icon = false,
			type = 'relative',
		},
	},
	'bg2',
	nil,
	nil,
	utf8.char(0xE0BA),
	utf8.char(0xE0BC),
	{
		truncate_hide = true,
	}
)


return {
	active = {
		-- Left
		{
			vi_mode_component,
			git_branch_component,
		},

		-- Center
		{
			file_info_component,
		},

		-- Right
		{
			file_encoding_component,
			file_type_component,
		},
	}
}
