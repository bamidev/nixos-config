local utf8 = require('utf8')


local this = {}


this.fancy_component = function(provider, color, side, neighbour, sep_left, sep_right, style)
	local function generate_sep_table(color_, sep_side)
		local table = {
			str = utf8.char(0x2588),
			hl = {
				fg = color_,
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
			table.hl.bg = neighbour.hl.bg
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
				bg = color(),
				style = style,
			}
		end
		sep_table_left = function()
			return generate_sep_table(color(), 'left')
		end
		sep_table_right = function()
			return generate_sep_table(color(), 'right')
		end
	else
		hl_base = { bg = color, style = style, }
		sep_table_left = generate_sep_table(color, 'left')
		sep_table_right = generate_sep_table(color, 'right')
	end

	local c = {
		provider = provider,
		hl = hl_base,
		left_sep = sep_table_left,
		right_sep = sep_table_right,
	}
	return c
end

this.simple_component = function(provider, color, style, options)
	local c = {
		provider = provider,
		hl = {
			fg = color,
			style = style,
		},
		truncate_hide = true,
	}
	if options ~= nil then
		for k, v in pairs(options) do c[k] = v end
	end
	return c
end


return this
