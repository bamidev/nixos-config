-- For user therp, only enable flake8 when using Odoo 14 or older.
-- Ruff can be used for the newer versions of Odoo because Ruff requires Python 3.7 or higher.
local odoo = require('utils.odoo')
local odoo_version = odoo.find_odoo_version()


local settings = {}
-- TODO: If not in a git repo, check if ./__manifest__.py exists, and parse the Odoo version from there...
if odoo_version ~= nil then
	settings = {
		basedpyright = {
			analysis = {
				-- The following reports are generally not working in Odoo projects
				--reportArgumentType = "none",
				--reportAttributeAccessIssue = "none",
				typeCheckingMode = "off";
			},
		},
		python = {
			pythonPath = '/home/therp/wax/' .. odoo_version .. '.0/wax/venv/bin/python';
		},
	}
end
vim.lsp.config('basedpyright', {
	settings = settings,
})
