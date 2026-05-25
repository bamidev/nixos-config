local odoo_version = require('utils.odoo').get_odoo_version() or 18

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
	handlers = {
		['window/showMessage'] = function(err, result, ctx)
			if result and result.message and result.message:find('4097') then
				return
			end
			return vim.lsp.handlers['window/showMessage'](err, result, ctx)
		end,
	},
}
