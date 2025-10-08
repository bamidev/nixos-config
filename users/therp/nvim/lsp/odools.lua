local lsp_dir = vim.fs.abspath('~/lsp')

local server_dir = lsp_dir .. '/odoo-ls/server'


local odoo_version = require('utils.odoo').find_odoo_version()
local odoo_profile = nil
if odoo_version ~= nil then odoo_profile = 'setup-' .. odoo_version end


return {
	cmd = {
		server_dir .. '/odoo_ls_server',
	},
	filetypes = { 'python', 'xml' },
	on_attach = function(client, _)
		vim.api.nvim_create_user_command('OdooProfile', function(e)
			local profile_name = e.args
			client.notify("workspace/didChangeConfiguration", {
				settings = {
					Odoo = {
						selectedProfile = profile_name
					}
				}
			})
		end, {
			desc = "Switch the profile used by the Odoo language server.",
			nargs = 1,
		})

		return require('autocomplete')
	end,
	root_markers = {'.git'},
	settings = {
		Odoo = {
			selectedProfile = odoo_profile
		},
	},
}
