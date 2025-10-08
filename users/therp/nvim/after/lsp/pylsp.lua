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
-- Disable import errors from pylint, because pylint is not aware of which Wax venv is being used,
-- and odoo-ls performs the same check while odoo-ls _is_ aware of the right venv used
-- Disable filename checking because migration scripts' filenames require an unconvential file name
-- style.
-- Disable function & module docstrings because migration scripts are not expected to have them.
--[[table.insert(
	settings.pylsp.plugins.pylint.args,
	"--disable=import-error,invalid-name,missing-function-docstring,missing-module-docstring"
)]]--
return {
	cmd = {'pylsp'},
	filetypes = {'python'},
	on_attach = require('autocomplete'),
	settings = settings,
	root_markers = {'flake.nix', '.git'}
}
