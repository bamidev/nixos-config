  -- TODO: Only enable this if the ESLint library is available
  vim.lsp.config('eslint', {
    cmd = {'vscode-eslint-language-server', '--stdio'},
    on_attach = require('autocomplete')
  })
