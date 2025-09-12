local luasnip = require("luasnip")
local i = luasnip.insert_node
local s = luasnip.snippet
local t = luasnip.text_node

local current_year = os.date("*t").year


return {
	s("model-file", {
		t({
			"# © " .. current_year .. " Therp B.V. (https://www.therp.nl)",
			"# License AGPL-3.0 or later (https://www.gnu.org/licenses/agpl.html).",
			"from odoo import fields, models",
			"",
			"",
		}),
		t("class "),
		i(1, "ClassName"),
		t({'(models.Model):', '    _name = "'}),
		i(2, "model.name"),
		t({'"', "", ""}),
	}),
}
