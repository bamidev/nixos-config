local c = require('plugins.feline.common')
local odoo = require('utils.odoo')


local issue_description = c.fancy_component(
	function()
		return odoo.find_issue_description() or ''
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
