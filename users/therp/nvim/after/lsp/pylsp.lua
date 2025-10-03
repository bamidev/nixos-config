local odoo_version = require('odoo').find_odoo_version()
local lsp_command = 'pylsp'
if odoo_version ~= nil then
	lsp_command = '/home/therp/wax/' .. odoo_version .. '/wax/venv/bin/pylsp'
end


return {
  cmd = {lsp_command},
  filetypes = {'python'},
  on_attach = require('autocomplete'),
  settings = require('pylsp').settings,
  root_markers = {'flake.nix', '.git'}
}
