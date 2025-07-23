# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, lib, ... }:

let
  config = import ./config.nix;
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
in
{
  imports = [
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
    ./apps.nix
    ./therp.nix
  ] ++ lib.optionals (config.environmentType == "desktop") [
    ./desktop/my-scripts.nix
  ];

  system.stateVersion = "24.11";

  boot.loader.grub = {
    splashMode = "stretch";
  } // lib.attrsets.optionalAttrs (builtins.pathExists /home/bamilab/Pictures/wallpapers/grub.png) {
    splashImage = /home/bamilab/Pictures/wallpapers/grub.png;
  };

  nix = {
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 90d";
    };

    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  networking = {
    hostName = "baminix";
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    resolvconf = {
      enable = true;
    };

    firewall.allowedUDPPorts = [ 53 67 ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Users
  users = {
    mutableUsers = true;
    users = if config.environmentType == "desktop" then {
      bamilab = {
        description = "Personal";
        home = "/home/bamilab";
        isNormalUser = true;
        extraGroups = [
          "audio"
          "video"
          "wheel"	# Enable ‘sudo’ for the user.
        ];
        #packages = with pkgs; [];
      };

      therp = {      
        description = "Work";
        home = "/home/therp";
        isNormalUser = true;
        extraGroups = [
          "audio"
          "docker"
          "video"
          "wheel"
        ];
        packages = with pkgs; [
          postgresql_17
        ];
      };

    } else {

      admin = {
        description = "Administrator";
        home = "/home/admin";
        isNormalUser = true;
        extraGroups = [ "wheel" ];

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4gv0OF52jorRoiylqIcsgZRtYp1aRmR9FQD7AwTt6Q bamidev@pm.me"
        ];
      };
    };
  };

  home-manager = {
    backupFileExtension = "backup";

    users =
      let
        defaults = import ./users/defaults.nix { pkgs=pkgs; };
      in
        if config.environmentType == "desktop" then
          let
            desktop = import ./users/desktop.nix { pkgs=pkgs; };
          in {
            bamilab = { lib, ... }: with lib.attrsets; recursiveUpdate 
              defaults (recursiveUpdate
                desktop
                (import ./users/bamilab.nix { pkgs=pkgs; lib=lib; })
              );
            therp = { lib, ... }: with lib.attrsets; recursiveUpdate 
              defaults (recursiveUpdate
                desktop
                (import ./users/therp.nix { pkgs=pkgs; lib=lib; })
              );
          }
        else {
          admin = { lib, ... }: lib.attrsets.recursiveUpdate
            defaults
            (import ./users/admin.nix { pkgs=pkgs; lib=lib; });
        };
  };

  security.polkit.enable = true;
}

