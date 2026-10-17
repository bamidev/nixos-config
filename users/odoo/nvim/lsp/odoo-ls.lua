local lsp_dir = vim.fs.abspath('~/lsp')
local server_dir = lsp_dir .. '/odoo-ls/server'
local odoo_version = require('utils.odoo').get_odoo_version()
--if odoo_version == nil then return {} end
local odoo_profile = 'setup-base'
if odoo_version ~= nil then
	odoo_profile = 'setup-' .. odoo_version .. '.0'
end
local home_dir = vim.uv.os_homedir()


return {
	name = "odoo-ls",
	cmd  = {
		'odoo_ls_server',
		-- The odoo-ls lsp server doesn't recognize the tilde sign, so we need to specify the full path:
		'--config-path', home_dir .. '/.config/odools.toml',
		'--logs-directory', home_dir .. '/lsp/odoo-ls-logs',
	},
	filetypes = {'csv', 'python', 'xml'},
	on_attach = function(client, _)
		vim.api.nvim_create_user_command('OdooProfile', function(e)
			local profile_name = e.args
			client.notify("workspace/didChangeConfiguration", {
				settings = {
					Odoo = { selectedProfile = profile_name }
				}
			})
		end, {
		  desc = "Switch the profile used by the Odoo language server.",
		  nargs = 1,
		})
	end,
	root_markers = {'.git'},
	settings = {
		Odoo = { selectedProfile = odoo_profile },
	},
	capabilities = require('lsp.capabilities'),
}
