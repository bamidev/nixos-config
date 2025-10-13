{ pkgs, ... }: ''
  return {
    cmd = {'${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server', '--stdio'},
    filetypes = {'css', 'less'},
    on_attach = require('autocomplete'),
  }
''
