local odoo = require('utils.odoo')
local odoo_version = odoo.find_odoo_version()
local python_path = odoo.pick_python_interpreter(odoo_version)


local settings = require('pylsp').settings
-- Override configurationSource to only pycodestyle, because when using both, the ~/.config/pycodestyle file isn't actually used for some reason.
settings.pylsp.plugins.jedi = { environment = python_path }
settings.pylsp.plugins.flake8.enabled = odoo_version ~= nil and tonumber(odoo_version) < 15
-- The following plugins don't know about migration scripts' built-in variables, so lets disable them:
--settings.pylsp.plugins.pyflakes.enabled = false
-- Disable import errors from pylint, because pylint is not aware of which Wax venv is being used,
-- and odoo-ls performs the same check while odoo-ls _is_ aware of the right venv used
-- Disable filename checking because migration scripts' filenames require an unconvential file name
-- style.
-- Disable function & module docstrings because migration scripts are not expected to have them.
-- Disable super().member checks because pylsp is not aware of all the members of the odoo base classes.
table.insert(
	settings.pylsp.plugins.pylint.args,
	"--disable=import-error,invalid-name,missing-function-docstring,missing-module-docstring,no-member"
)
return {
	cmd = {'pylsp'},
	filetypes = {'python'},
	settings = settings,
	root_markers = {'flake.nix', '.git'}
}
