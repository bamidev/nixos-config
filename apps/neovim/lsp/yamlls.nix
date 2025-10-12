{ pkgs, ... }: ''
  return {
    cmd = {'${pkgs.yaml-language-server}/bin/yaml-language-server', '--stdio'},
    filetypes = {'yaml'},
    on_attach = require('autocomplete'),
  }
''
