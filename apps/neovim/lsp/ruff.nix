{ pkgs, ... }: ''
  vim.lsp.config('ruff', {
    cmd = {'${pkgs.ruff}/bin/ruff', 'server'},
    filetypes = {'python'},
    on_attach = require('autocomplete'),
    root_markers = {'requirements.txt', '.git'}
  })
''
