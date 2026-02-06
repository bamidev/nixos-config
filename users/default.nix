{ lib, ... }:
let
  oldPkgs = (import ../sources.nix).nixpkgs25_05.pkgs;
in {
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

      ".config/ruff.toml" = lib.mkDefault {
        text = ''
          extend = "/etc/ruff.toml"
        '';
      };
    };

    sessionVariables = {
      "VIMINIT" = ''
        nmap ; :
        vmap ; :
        source ~/.config/nvim/init.lua
      '';
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
      package = oldPkgs.gitFull;
    };
  };

  xdg.enable = true;
}
