local this = {}


local current_year = os.date("*t").year


this.LICENSE_HEADER = {
	"Copyright " .. current_year .. " Therp BV (https://www.therp.nl).",
	"License AGPL-3.0 or later (https://www.gnu.org/licenses/agpl.html).",
}


return this
