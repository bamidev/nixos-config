{ pkgs, ... }: ''
  return {
    cmd = {'${pkgs.java-language-server}/bin/java-language-server'},
    filetypes = {'java'},
    root_markers = {'.git'},
    on_attach = require('autocomplete'),
    settings = {}
  }
''
