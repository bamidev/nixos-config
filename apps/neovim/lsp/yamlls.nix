{ pkgs, ... }: ''
  vim.lsp.config('yamlls', {
    cmd = {'${pkgs.yaml-language-server}/bin/yaml-language-server', '--stdio'},
    filetypes = {'yaml'},
  })
''
