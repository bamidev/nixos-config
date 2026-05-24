{ pkgs }: ''
  vim.lsp.config('postgres_lsp', {
    cmd = { "${pkgs.postgres-language-server}/bin/postgrestools", "lsp-proxy" },
    filetypes = {'sql'},
    root_markers = { 'postgrestools.jsonc' },
  })
''
