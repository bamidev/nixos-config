{ pkgs, ... }: ''
  vim.lsp.config('ruff', {
    cmd = {'${pkgs.ruff}/bin/ruff', 'server'},
    init_options = {
        settings = {
          configuration = '~/.config/ruff.toml',
          configurationPreference = 'filesystemFirst',
      },
    },
	  capabilities = require('lsp.capabilities')
  })
''
