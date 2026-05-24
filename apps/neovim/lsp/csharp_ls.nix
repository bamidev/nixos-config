{ pkgs, ... }: ''
  vim.lsp.config('csharp_ls', {
    cmd = {'${pkgs.csharp-ls}/bin/csharp-ls'},
    root_markers = {'.git'},
  })
''
