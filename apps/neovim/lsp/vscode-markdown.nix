{ pkgs, ... }: ''
  return {
    cmd = {'${pkgs.vscode-langservers-extracted}/bin/vscode-markdown-language-server', '--stdio'},
    filetypes = {'markdown'},
    on_attach = require('autocomplete'),
  }
''
