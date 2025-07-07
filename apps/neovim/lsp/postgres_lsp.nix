{ pkgs }: ''
  return {
    cmd = { "${pkgs.postgres-lsp}/bin/postgrestools", "lsp-proxy" },
    on_attach = require('autocomplete'),
    filetypes = {'sql'},
    root_markers = { 'postgrestools.jsonc' },
  }
''
