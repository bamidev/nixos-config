local luasnip = require('luasnip')
local ls_extras = require('luasnip.extras')
local license = require('snippets.license')
local odoo = require('utils.odoo')

local i = luasnip.insert_node
local r = ls_extras.rep
local s = luasnip.snippet
local t = luasnip.text_node

local odoo_version = odoo.get_odoo_version() or 0


return {
	s('config-param-file', {
		t({
			'#' .. license.LICENSE_HEADER[1],
			'#' .. license.LICENSE_HEADER[2],
			'from odoo import fields, models',
			'',
			'',
			'class ResConfigSettings(models.TransientModel):',
			'    '
		}),
		i(1, 'parameter'),
		t(' = fields.'),
		i(2, 'Boolean'),
		t('("'),
		i(3, 'Description...'),
		t('"'),
		odoo_version >= 14 and {
			t({
				',',
				'config_parameter="'
			}),
			i(4, 'module_name'),
			t('.'),
			r(1),
			t('"')
		} or {},
		t(')'),
		-- TODO: If Odoo version is old, add the get_values and set_values methods
	})
}
