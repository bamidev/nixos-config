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
		return (utf8.char(0xE0A0) .. ' ' .. git.get_branch()) or ''
	end,
	'oceanblue',
	'left'
)
local issue_number = c.fancy_component(
	function()
		local number = odoo.find_task_number()
		if number ~= nil then
			return '#' .. tostring(number)
		end
		return ''
	end,
	'orange',
	'left',
	issue_description
)
local odoo_version = c.fancy_component(
	function()
		return odoo.find_odoo_version() or ''
	end,
	'magenta',
	'left',
	issue_number
)


return {
	odoo_version,
	issue_number,
	issue_description,
}
