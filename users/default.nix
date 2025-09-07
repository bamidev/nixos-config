{ pkgs, lib, username, ... }: {
  home.stateVersion = "24.11";

  accounts.email.accounts."Personal" = rec {
    primary = true;
    thunderbird.enable = true;

    realName = "Danny de Jong";
    address = "danny.de.jong@pm.me";
    userName = address;

    imap = {
      host = "127.0.0.1";
      port = 1143;
      tls.useStartTls = true;
    };

    smtp = {
      host = "127.0.0.1";
      port = 1025;
      tls.useStartTls = true;
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

    # For some reason, neovim will not be invoked with the -u flag for the customRC code as non-root users,
    # which should load my init.lua file .
    # This is a workaround which will still load the init.lua file even for non-root users.
    neovim = {
      enable = true;
      extraConfig = ''
        luafile /etc/xdg/nvim/init.lua
      '';
    };

    thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };
  };

  xdg.enable = true;
}
