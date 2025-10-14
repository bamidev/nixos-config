{ pkgs }: ''
  vim.lsp.config('markdown_oxide', {
    cmd = {'${pkgs.markdown-oxide}/bin/markdown-oxide'},
    on_attach = require('autocomplete'),
  })
''
