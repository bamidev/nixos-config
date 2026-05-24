{ pkgs }: ''
  vim.lsp.config('nixd', {
    cmd = { "${pkgs.nixd}/bin/nixd" },
    filetypes = { 'nix' },
    root_markers = { 'flake.nix', '.git' },
  })
''
