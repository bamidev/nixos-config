{ pkgs, ... }:
let
  params = import ../config.nix;
in if params.environmentType == "desktop" then {
  imports = [
    ./default.nix
    ../apps/alacritty.nix
    ../apps/freetube.nix
    ../apps/librewolf.nix
    ../apps/neovim/home.nix
    ../apps/sway/home.nix
    ../apps/todo-txt.nix
  ];

  programs = {
    bash = {
      profileExtra = ''
        #!${pkgs.bash}/bin/bash
        if [ -e ~/.init.sh ]; then
          . ~/.init.sh
        fi
      '';
      shellAliases = {
        "todo" = "todo.sh";
      };
      initExtra = ''
        CURRENT_WORKSPACE=$(current-workspace)
        if [ "$PWD" == "$HOME" ] && [ -f ~/.here/$CURRENT_WORKSPACE ]; then
          cd $(cat ~/.here/$CURRENT_WORKSPACE)
        fi
      '';
    };

    element-desktop = {
      enable = true;
      settings = {
        default_theme = "dark";
      };
    };
  };
} else {
  imports = [
    ./default.nix
  ];
}
