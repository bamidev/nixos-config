{ pkgs, ... }: {
  home.stateVersion = "24.11";

  imports = [];

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

    # For some reason, neovim will not be invoked with the -u flag for the customRC code as non-root users,
    # which should load my init.lua file .
    # This is a workaround which will still load the init.lua file even for non-root users.
    neovim = {
      enable = true;
      extraConfig = ''
        luafile /etc/xdg/nvim/init.lua
      '';
    };
  };
}
