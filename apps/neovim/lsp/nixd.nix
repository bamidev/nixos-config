{ pkgs }: ''
  return {
    cmd = { "${pkgs.nixd}/bin/nixd" },
    on_attach = require('autocomplete'),
    filetypes = { 'nix' },
    root_markers = { 'flake.nix', '.git' },
  }
''
