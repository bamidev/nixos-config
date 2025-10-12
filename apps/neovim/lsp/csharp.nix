{ pkgs, ... }: ''
  return {
    cmd = {'${pkgs.csharp-ls}/bin/csharp-ls'},
    filetypes = {'cs'},
    on_attach = require('autocomplete'),
    init_options = {
      AutomaticWorkspaceInit = true
    },
    root_markers = {'.git'},
  }
''
