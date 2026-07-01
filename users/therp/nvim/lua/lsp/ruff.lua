local odoo = require('utils.odoo')
local version = odoo.find_odoo_version()


if version == nil or tonumber(version) >= 15 then
	local python_interpreter = odoo.pick_python_interpreter(version)
	vim.lsp.config('ruff', {
		init_options = {
			settings = {
				configuration = '~/.config/ruff.toml',
				configurationPreference = 'filesystemFirst',
				interpreter = python_interpreter,
			},
		},
	})
else
	-- Disable the language server when Odoo is too old, by not loading it for python files
	vim.lsp.config('ruff', {
		filetypes = {},
	})
end
