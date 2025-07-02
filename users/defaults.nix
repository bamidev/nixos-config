{ pkgs }: {
  home.stateVersion = "24.11";

  imports = [
    ../apps/alacritty.nix
    ../apps/sway/home.nix
    ../apps/todo-txt.nix
  ];


  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
      
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
        if [ -f ~/.here/$CURRENT_WORKSPACE ]; then
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

    # For some reason, neovim will not be invoked with the -u flag for the customRC code as non-root users,
    # which should load my init.lua file .
    # This is a workaround which will still load the init.lua file even for non-root users.
    neovim = {
      enable = true;
      extraConfig = ''
        lua << EOF
          ${import ../apps/neovim/init.nix { pkgs = pkgs; }}
        EOF
      '';
    };
  };
}
