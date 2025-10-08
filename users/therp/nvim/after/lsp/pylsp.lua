local odoo_version = require('utils.odoo').find_odoo_version()
local python_path = 'python'
if odoo_version ~= nil then
	python_path = '/home/therp/wax/' .. odoo_version .. '/wax/venv/bin/python'
end


local settings = require('pylsp').settings
settings.pylsp.plugins.jedi = { environment = python_path }
-- Th following plugins don't know about built-in variables
settings.pylsp.plugins.flake8.enabled = false
settings.pylsp.plugins.pyflakes.enabled = false
return {
	cmd = {'pylsp'},
	filetypes = {'python'},
	on_attach = require('autocomplete'),
	settings = settings,
	root_markers = {'flake.nix', '.git'}
}
