# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }:

let
  config = import ./config.nix;
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
in
{
  imports =
    [
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
      ./apps.nix
      ./my-scripts.nix
      ./therp.nix
    ];

  system.stateVersion = "24.11";

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

  networking.hostName = "baminix"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.resolvconf = {
    enable = true;
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

