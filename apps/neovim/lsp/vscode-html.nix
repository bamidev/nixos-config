{ pkgs, ... }: ''
  return {
    cmd = {'${pkgs.vscode-langservers-extracted}/bin/vscode-html-language-server', '--stdio'},
    filetypes = {'html'},
    on_attach = require('autocomplete'),
  }
''
