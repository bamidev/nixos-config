{ pkgs, ... }: ''
  -- TODO: Only enable this if the ESLint library is available
  vim.lsp.config('eslint', {
    cmd = {'${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server', '--stdio'},
    settings = {
      nodePath = '${pkgs.nodejs_24}/bin/node',
    },
  })
''
