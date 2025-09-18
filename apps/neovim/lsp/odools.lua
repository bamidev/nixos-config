local lsp_dir = vim.fs.abspath('~/lsp')
local code_dir = vim.fs.abspath('~/code')

local server_dir = lsp_dir .. '/odoo-ls/server'
-- Get the default client capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Add your custom capability
capabilities.general.markdown = {
  parser = 'marked',
  version = ""
}
return {
  cmd = {
    lsp_dir .. '/odoo-ls/server/target/release/odoo_ls_server',
    '--stdlib',
    server_dir .. '/typeshed/stdlib'
  },
  root_dir = server_dir,
  filetypes = { 'python' },
  workspace_folders = {{
      uri = vim.uri_from_fname(code_dir),
      name = 'main_folder',
  }},
  capabilities = capabilities,
  settings = {
      Odoo = {
          selectedProfile = 'main',
      }
  },
}
