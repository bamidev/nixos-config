local luasnip = require("luasnip")
local license = require('snippets.license')

local c = luasnip.choice_node
local i = luasnip.insert_node
local s = luasnip.snippet
local t = luasnip.text_node


local function field_header(type)
	return {
		i(1, 'field_name'),
		t(' = fields.' .. type .. '('),
	}
end

local function simple_field(type)
	local nodes = field_header(type)
	table.insert(nodes, i(2))
	table.insert(nodes, t(')'))
	return nodes
end

local function bool_param(name)
	return {
		t(name .. '='),
		c(1, {
			t('True'),
			t('False'),
		}),
	}
end

local function x2x_field(type)
	local h = field_header(type)
	return {
		h[1],
		h[2],
		t('"'),
		i(2, 'model.name'),
		t('"'),
		i(3, ''),
		t(')')
	}
end


return {
	s('bool', simple_field('Boolean')),
	s('bin', simple_field('Binary')),
	s('char', simple_field('Char')),
	s('float', simple_field('Float')),
	s('int', simple_field('Integer')),
	s('license', {
		t({
			'# ' .. license.LICENSE_HEADER[1],
			'# ' .. license.LICENSE_HEADER[2],
			'', ''
		}),
	}),
	s('m2m', x2x_field('Many2many')),
	s('m2o', x2x_field('Many2one')),
	s('migration-file', t({
		'# ' .. license.LICENSE_HEADER[1],
		'# ' .. license.LICENSE_HEADER[2],
		'from openupgradelib import openupgrade',
		'',
		'',
		'@openupgrade.migrate()',
		'def migrate(env, _version):',
		'    ',
	})),
	s("model-file", {
		t({
			'# ' .. license.LICENSE_HEADER[1],
			'# ' .. license.LICENSE_HEADER[2],
			"from odoo import fields, models",
			"",
			"",
		}),
		t("class "),
		i(1, "ClassName"),
		t({'(models.Model):', ''}),
		c(2, {
			{
				t('    _name = "'),
				i(1, "model.name"),
				t({
					'"',
					'    _description = "'
				}),
				i(2, "Model desciption"),
			},
			{
				t('    _inherit = "'),
				i(1, "model.name"),
			},
		}),
		t({'"', '', ''}),
	}),
	s('o2m', x2x_field('One2many')),
	s('read', bool_param('readonly')),
	s('str', {
		t('string="'),
		i(1),
		t('"'),
	}),
}
