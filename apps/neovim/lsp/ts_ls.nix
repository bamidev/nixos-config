{ pkgs, ... }: ''
  vim.lsp.config('ts_ls', {
    cmd = {'${pkgs.typescript-language-server}/bin/typescript-language-server', '--stdio'},
    on_attach = require('autocomplete'),
  })
''
