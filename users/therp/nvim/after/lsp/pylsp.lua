-- For user therp, only enable flake8 when using Odoo 14 or older.
-- Ruff can be used for the newer versions of Odoo because Ruff requires Python 3.7 or higher.
local odoo = require('utils.odoo')
local odoo_version = odoo.find_odoo_version()
local python_path = odoo.pick_python_interpreter(odoo_version)


local settings = require('pylsp').settings
settings.pylsp.plugins.jedi = { environment = python_path }
settings.pylsp.plugins.flake8.enabled = odoo_version ~= nil and tonumber(odoo_version) < 15

local command = 'pylsp'
-- TODO: If not in a git repo, check if ./__manifest__.py exists, and parse the Odoo version from there...
if odoo_version ~= nil then
	command = '/home/therp/wax/' .. odoo_version .. '/wax/venv/bin/pylsp'
end
vim.lsp.config('pylsp', {
	cmd = {command},
	filetypes = {'python'},
	settings = settings,
	root_markers = {'flake.nix', '.git'}
})
