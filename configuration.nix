# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, lib, ... }:

let
  config = import ./params.nix;
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
  theme = import ./theme.nix;
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

  boot = {
    # Completely disable the IPv6 stack in order to prevent IPv6 from being used; it is not
    # supported by the VPN.
    kernelParams = [ "ipv6.disable=1" ];

    loader.grub = {
      enable = true;
    } // lib.attrsets.optionalAttrs (builtins.pathExists /home/bamilab/Pictures/wallpapers/grub.jpg) {
      splashImage = /home/bamilab/Pictures/wallpapers/grub.jpg;
      splashMode = "stretch";
    };
  };

  console.colors = [
    theme.dark.black
  ] ++ (with theme.normal; [
    red
    green
    yellow
    blue
    magenta
    cyan
    white
  ]) ++ (with theme.bright; [
    black
    red
    green
    yellow
    blue
    magenta
    cyan
    white
  ]);

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
    enableIPv6 = false;
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
    users = {
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

    } // lib.attrsets.optionalAttrs (config.environmentType != "desktop") {

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
      {
        bamilab = { pkgs, lib, ... }:
          import ./users/bamilab.nix { pkgs=pkgs; lib=lib; username="bamilab"; };
        therp = { pkgs, lib, ... }:
          import ./users/therp.nix { pkgs=pkgs; lib=lib; username="therp"; };
      } // lib.attrsets.optionalAttrs (config.environmentType != "desktop") {
        admin = { pkgs, lib, ... }:
          import ./users/admin.nix { pkgs=pkgs; lib=lib; username="admin"; };
      };
  };

  security.polkit.enable = true;
}

