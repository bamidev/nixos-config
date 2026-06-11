{ lib, inputs, ... }:
let
  editorPkgs = inputs.editorPkgs.legacyPackages.${builtins.currentSystem};
in
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
      package = editorPkgs.gitFull;
    };
  };

  xdg.enable = true;
}
