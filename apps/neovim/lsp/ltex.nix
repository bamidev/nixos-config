{ pkgs, ... }: ''
  vim.lsp.config('ltex', {
    cmd = {'${pkgs.ltex-ls}/bin/ltex-ls'},
    settings = {
      ltex = {
        language = 'en-US',
      }
    },
    root_markers = {'.git'},
  })
''
