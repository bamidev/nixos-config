local luasnip = require("luasnip")
local license = require('snippets.license')
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
		t({
			'(models.Model):',
			'    _name = "'
		}),
		i(2, "model.name"),
		t({'"', "", ""}),
	}),
}
