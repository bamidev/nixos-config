{ pkgs }: {
  imports = [
    ../apps/alacritty.nix
    ../apps/librewolf.nix
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

        sway
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
}
