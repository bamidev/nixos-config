local odoo_version = require('utils.odoo').get_odoo_version()
if odoo_version == nil or odoo_version >= 16 then return {} end
-- odoo-lsp seems to give INVALID_SERVER_MESSAGE errors in an odoo 16 & 19 project of mine, so I'm assuming it doesn't play well together (yet) with Odoo 16 or higher.


local project_dir = vim.fs.root(0, {'.git'})
local wax_dir = '/home/therp/wax/' .. odoo_version .. '.0/wax/addons'
return {
	name = 'odoo-lsp',
	cmd = {'odoo-lsp'},
	filetypes = {'python', 'xml', 'javascript'},
	capabilities = require('lsp.capabilities'),
	root_markers = {'.git'},
	workspace_folders = {
		{ uri = 'file://' .. project_dir, name = 'project dir' },
		{ uri = 'file://' .. wax_dir, name = 'Wax ' .. odoo_version .. '.0 instance', },
	},
}
