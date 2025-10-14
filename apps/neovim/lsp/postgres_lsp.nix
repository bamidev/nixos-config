{ pkgs }: ''
  vim.lsp.config('postgres_lsp', {
    cmd = { "${pkgs.postgres-lsp}/bin/postgrestools", "lsp-proxy" },
    on_attach = require('autocomplete'),
    filetypes = {'sql'},
    root_markers = { 'postgrestools.jsonc' },
  })
''
