{ lib, pkgs, ... }: ''
  vim.g.cargo_path = '${pkgs.rustup}/bin/cargo';
  vim.g.gnumake_path = '${lib.getExe pkgs.gnumake}';
  vim.g.python_path = '${lib.getExe pkgs.python314}';


  vim.cmd('luafile /etc/xdg/extra-config/neovim/init.lua')
''
