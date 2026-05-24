{ pkgs, ... }: ''
  vim.lsp.config('java-language-server', {
    cmd = {'${pkgs.java-language-server}/bin/java-language-server'},
  })
''
