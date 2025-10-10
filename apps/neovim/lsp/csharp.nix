{ pkgs, ... }: ''
  return {
    cmd = {'${pkgs.csharp-ls}/bin/csharp-ls'},
    filetypes = {'cs'},
    init_options = {
      AutomaticWorkspaceInit = true
    },
    root_markers = {'.git'},
  }
''
