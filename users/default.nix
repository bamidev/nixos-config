{ lib, pkgs, ... }:
{
  imports = [
    ../apps/neovim/home.nix
  ];

  home = {
    stateVersion = "24.11";

    file = {
      ".config/nvim/init.lua" = lib.mkDefault {
        text = ''
          vim.cmd('luafile /etc/xdg/nvim/init.lua')
        '';
      };

      ".config/pylintrc" = lib.mkDefault {
        source = ../apps/neovim/etc/pylintrc;
      };
    };
  };

  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
      enableCompletion = true;
    };

    git = {
      enable = true;
      package = pkgs.gitFull;
    };
  };

  xdg.enable = true;
}
