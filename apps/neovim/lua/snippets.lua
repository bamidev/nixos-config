local this = {}
local luasnip = require('luasnip')


local current_year = os.date("*t").year


function this.setup()
	luasnip.add_snippets('gitcommit', require('snippets.gitcommit'))
	luasnip.add_snippets('python', require('snippets.python'))
	luasnip.add_snippets('xml', require('snippets.xml'))
end


this.LICENSE_HEADER = {
	"© " .. current_year .. " Therp B.V. (https://www.therp.nl)",
	"License AGPL-3.0 or later (https://www.gnu.org/licenses/agpl.html).",
}


return this
