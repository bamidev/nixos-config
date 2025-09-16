{ lib, pkgs, ... }: {
  home = {
    stateVersion = "24.11";

    file = {
      ".config/pylintrc" = lib.mkDefault {
        source = /etc/nixos/apps/neovim/etc/pylintrc;
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
