{ pkgs, ... }: ''
  vim.lsp.config('ruff', {
    cmd = {'${pkgs.ruff}/bin/ruff', 'server'},
    filetypes = {'python'},
    root_markers = {'requirements.txt', '.git'}
  })
''
