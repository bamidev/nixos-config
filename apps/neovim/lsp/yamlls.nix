{ pkgs, ... }: ''
  return {
    cmd = {'${pkgs.yaml-language-server}/bin/yaml-language-server', '--stdio'},
    filestypes = {'yaml'},
    on_attach = require('autocomplete')
  }
''
