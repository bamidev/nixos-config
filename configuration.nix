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
  ] ++ lib.optionals (config.environmentType == "desktop") [
    ./desktop/my-scripts.nix
  ];

  system.stateVersion = "24.11";

  boot.loader.grub = {
    enable = true;
  } // lib.attrsets.optionalAttrs (builtins.pathExists /home/bamilab/Pictures/wallpapers/grub.jpg) {
    splashImage = /home/bamilab/Pictures/wallpapers/grub.jpg;
    splashMode = "stretch";
  };

  console.colors = [
    "1d2021"
    "cc241d"
    "98971a"
    "d79921"
    "458588"
    "b16286"
    "689d6a"
    "a89984"
    "282828"
    "fb4934"
    "b8bb26"
    "fabd2f"
    "83a598"
    "d3869b"
    "8ec07c"
    "ebdbb2"
  ];

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

    # Use the `imports` feature because now the imports list of users/defaults.nix is being
    # overriden by the other files.
    users =
      let
        defaults = import ./users/defaults.nix;
        desktop = import ./users/desktop.nix { pkgs=pkgs; };
      in {
        bamilab = { lib, ... }: with lib.attrsets; recursiveUpdate 
          (defaults { pkgs=pkgs; username="bamilab"; }) (recursiveUpdate
            desktop
            (import ./users/bamilab.nix { pkgs=pkgs; lib=lib; username="bamilab"; })
          );
        therp = { lib, ... }: with lib.attrsets; recursiveUpdate 
          (defaults { pkgs=pkgs; username="therp"; }) (recursiveUpdate
            desktop
            (import ./users/therp.nix { pkgs=pkgs; lib=lib; username="therp"; })
          );
      } // lib.attrsets.optionalAttrs (config.environmentType != "desktop") {
        admin = { lib, ... }: lib.attrsets.recursiveUpdate
          defaults
          (import ./users/admin.nix { pkgs=pkgs; lib=lib; });
      };
  };

  security.polkit.enable = true;
}

