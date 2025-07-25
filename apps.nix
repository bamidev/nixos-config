{ pkgs, lib, ... }:
let
  config = import ./config.nix;
in {
  imports =
    [
      ./apps/neovim/system.nix
      ./apps/syncthing/system.nix
    ] ++ lib.optionals (config.environmentType == "desktop") [
      ./apps/desktop.nix
    ] ++ lib.optionals (config.environmentType == "nas") [
      ./apps/server.nix
    ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    etc = {
      gitconfig.text = ''
        [alias]
        a = "add"
        b = "branch"
        c = "checkout"
        cm = "commit"
        d = "diff"
        l = "log"
        p = "pull"
        s = "status"

        [core]
        editor = "nvim"
        abbrev = 7

        [push]
        autoSetupRemote = true
      '';

      "gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=Adwaita:dark
        gtk-application-prefer-dark-theme=1
      '';
    };

    shellAliases = {
      g = "git";
      gb = "git branch";
      gd = "git diff";
      gs = "git status";
    };

    systemPackages = with pkgs; [
      bc
      killall
      nix-index
      nixfmt-rfc-style
      openssh
      pass
      syncthing
      w3m
      wget
    ];
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}

