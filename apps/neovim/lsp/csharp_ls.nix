{ pkgs, ... }: ''
  vim.lsp.config('csharp_ls', {
    cmd = {'${pkgs.csharp-ls}/bin/csharp-ls'},
    on_attach = require('autocomplete'),
    root_markers = {'.git'},
  })
''
