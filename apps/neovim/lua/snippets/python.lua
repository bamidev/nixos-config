local luasnip = require("luasnip")
local common = require('snippets')
local i = luasnip.insert_node
local s = luasnip.snippet
local t = luasnip.text_node


return {
	s("model-file", {
		t({
			'# ' .. common.LICENSE_HEADER[1],
			'# ' .. common.LICENSE_HEADER[2],
			"from odoo import fields, models",
			"",
			"",
		}),
		t("class "),
		i(1, "ClassName"),
		t({
			'(models.Model):',
			'    _name = "'
		}),
		i(2, "model.name"),
		t({'"', "", ""}),
	}),
}
