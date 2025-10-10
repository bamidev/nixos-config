local c = require('plugins.feline.common')
local vi_mode = require('feline.providers.vi_mode')
local utf8 = require('utf8')


local errors_component = c.simple_component('diagnostic_errors', 'red')
errors_component.priority = 7

local file_encoding_component = c.fancy_component('file_encoding', 'skyblue', 'right')

local file_info_component = c.fancy_component(
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
	' ' .. utf8.char(0xE0BA),
	utf8.char(0xE0BC) .. ' ',
	nil
)
file_info_component.priority = 8
file_info_component.short_provider = {
	name = 'file_info',
	opts = {
		colored_icon = false,
		type = 'relative-short',
	}
}
file_info_component.truncate_hide = true

local file_type_component = c.fancy_component(
	function()
		return vim.bo.filetype or ''
	end,
	function()
		local table = {
			c = 'bg4',
			cpp = 'blue',
			gitcommit = 'red',
			lua = 'blue',
			python = 'yellow',
			html = 'orange',
			nix = 'faded_blue',
			rust = 'faded_orange',
			sh = 'dark_green',
			xml = 'bright_blue',
		}

		local color = table[vim.bo.filetype]
		if color ~= nil then
			return color
		end
		return "grey"
	end,
	'right',
	file_encoding_component,
	nil,
	nil,
	'bold'
)


local git_branch_components = require('plugins.feline.components.git_branch')

local git_added_component = c.simple_component('git_diff_added', 'green')
git_added_component.priority = 3

local git_changed_component = c.simple_component('git_diff_changed', 'yellow')
git_changed_component.icon = ' M '
git_changed_component.priority = 2

local git_removed_component = c.simple_component('git_diff_removed', 'orange')
git_removed_component.priority = 1

local hints_component = c.simple_component('diagnostic_hints', 'cyan')
hints_component.priority = 5

local infos_component = c.simple_component('diagnostic_info', 'blue')
infos_component.priority = 4

local vi_mode_component = c.fancy_component(
	'vi_mode',
	function()
		return vi_mode.get_mode_color()
	end,
	'left',
	git_branch_components[1],
	nil,
	nil,
	'bold'
)
vi_mode_component.icon = ''

local warnings_component = c.simple_component('diagnostic_warnings', 'yellow')
warnings_component.priority = 6


local components = {
	active = {
		-- Left
		{
			vi_mode_component,
			git_branch_components[1],
		},

		-- Center
		{
			git_added_component,
			git_changed_component,
			git_removed_component,
			file_info_component,
			errors_component,
			warnings_component,
			infos_component,
			hints_component,
		},

		-- Right
		{
			file_encoding_component,
			file_type_component,
		},
	}
}

-- Add any remaining git branch components if available
-- This allows replacing the default git branch component with any number of other components on
-- the user level.
-- For example, you could replace it with one or more components that display more specific
-- information gathered from git. 
for i = 2, #git_branch_components do
	table.insert(components.active[1], git_branch_components[i])
end

return components
