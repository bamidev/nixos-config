local luasnip = require("luasnip")
local license = require('snippets.license')

local c = luasnip.choice_node
local i = luasnip.insert_node
local s = luasnip.snippet
local t = luasnip.text_node


return {
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
}
