{ pkgs, ... }: ''
  return {
    cmd = {'${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server', '--stdio'},
    filetypes = {'json'},
    on_attach = require('autocomplete'),
    init_options = {
      provideFormatter = true,
    },
  }
''
