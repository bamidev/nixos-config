vim.lsp.config('pylsp', {
  cmd = {'pylsp'},
  filetypes = {'python'},
  on_attach = require('autocomplete'),
  settings = require('pylsp').settings,
  root_markers = {'requirements.txt', '.git'}
})
