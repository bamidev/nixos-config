local c = require('plugins.feline.common')
local git = require('utils.git')
local odoo = require('utils.odoo')
local utf8 = require('utf8')


local issue_description = c.fancy_component(
	function()
		-- FIXME: This currently executes the underlying git command multiple times
		if odoo.find_task_number() ~= nil then
			return odoo.find_issue_description() or ''
		end
		local branch = git.get_branch()
		if branch ~= nil then
			return utf8.char(0xE0A0) .. ' ' .. branch
		end
		return ''
	end,
	'bg_aqua',
	'right'
)
issue_description.update = {'BufEnter'}
local issue_number = c.fancy_component(
	function()
		local number = odoo.find_task_number()
		if number ~= nil then
			return '#' .. tostring(number)
		end
		return ''
	end,
	'bg_orange',
	'right',
	issue_description
)
issue_number.update = {'BufEnter'}
local odoo_version = c.fancy_component(
	function()
		local v = odoo.get_odoo_version()
		if v then
			return tostring(v) .. '.0'
		end
		return ''
	end,
	'bg_purple',
	'right',
	issue_number
)
odoo_version.update = {'BufEnter'}


return {
	odoo_version,
	issue_number,
	issue_description,
}
