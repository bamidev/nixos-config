{ pkgs, ... }: ''
  return {
    cmd = {'${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server', '--stdio'},
    filetypes = {'javascript'},
    on_attach = require('autocomplete'),
    root_markers = {'.git'},
  }
''
