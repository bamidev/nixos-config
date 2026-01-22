local odoo = require('utils.odoo')
local odoo_version = odoo.find_odoo_version()
local python_path = odoo.pick_python_interpreter(odoo_version)


local settings = require('pylsp').settings
-- Override configurationSource to only pycodestyle, because when using both, the ~/.config/pycodestyle file isn't actually used for some reason.
settings.pylsp.plugins.jedi = { environment = python_path }
settings.pylsp.plugins.flake8.enabled = odoo_version ~= nil and tonumber(odoo_version) < 15

local command = 'pylsp'
if odoo_version ~= nil then
	command = '/home/therp/wax/' .. odoo_version .. '/wax/venv/bin/pylsp'
end
vim.lsp.config('pylsp', {
	cmd = {command},
	filetypes = {'python'},
	settings = settings,
	root_markers = {'flake.nix', '.git'}
})
