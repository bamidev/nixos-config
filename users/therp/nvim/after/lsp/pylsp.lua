-- For user therp, only enable flake8 when using Odoo 14 or older.
-- Ruff can be used for the newer versions of Odoo because Ruff requires Python 3.7 or higher.
local odoo = require('utils.odoo')
local odoo_version = odoo.find_odoo_version()


local settings = require('pylsp').settings
local not_replaced_by_ruff = odoo_version ~= nil and tonumber(odoo_version) < 15
settings.pylsp.plugins.autopep8.enabled = not_replaced_by_ruff
settings.pylsp.plugins.mccabe.enabled = not_replaced_by_ruff
settings.pylsp.plugins.pyflakes.enabled = not_replaced_by_ruff

local command = 'pylsp'
-- TODO: If not in a git repo, check if ./__manifest__.py exists, and parse the Odoo version from there...
if odoo_version ~= nil then
	command = '/home/therp/wax/' .. odoo_version .. '.0/wax/venv/bin/pylsp'
end
vim.lsp.config('pylsp', {
	cmd = {command},
	filetypes = {'python'},
	settings = settings,
	root_markers = {'flake.nix', '.git'}
})
