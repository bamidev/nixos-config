# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, lib, ... }:

let
  deviceConfig = import ./device.nix;
  homeManager = (import ./sources.nix).homeManager26_05;
  params = import ./params.nix;
  theme = import ./theme.nix;
in
{
  imports = [
    "/etc/nixos/devices/${deviceConfig.name}/hardware.nix"
    homeManager
    ./apps.nix
  ] ++ lib.optionals (params.environmentType == "desktop") [
    ./desktop.nix
  ];

  system.stateVersion = "24.11";

  boot = {
    tmp.cleanOnBoot = true;

    # Completely disable the IPv6 stack in order to prevent IPv6 from being used; it is not
    # supported by my VPN.
    kernelParams = [
      "console=tty12"
      "ipv6.disable=1"
    ];

    loader = {
      grub = {
        enable = true;
      } // lib.attrsets.optionalAttrs (builtins.pathExists /home/bamilab/Pictures/grub.png) {
        splashImage = /home/bamilab/Pictures/grub.png;
        splashMode = "stretch";
      };
      timeout = 2;
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

  hardware.enableAllFirmware = lib.mkDefault false;
  hardware.enableRedistributableFirmware = lib.mkDefault false;

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
          "docker"
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
    };
  };

  home-manager = {
    backupFileExtension = "backup";

    # Use the `imports` feature because now the imports list of users/defaults.nix is being
    # overriden by the other files.
    users =
      {
        root = { pkgs, lib, ... }: import ./users/root.nix { pkgs=pkgs; lib=lib; };
        bamilab = { pkgs, lib, ... }:
          import ./users/bamilab.nix { pkgs=pkgs; lib=lib; };
      } // lib.attrsets.optionalAttrs (params.environmentType == "desktop") {
        therp = { pkgs, lib, ... }:
          import ./users/therp.nix { pkgs=pkgs; lib=lib; };
      };
  };

  security.polkit.enable = true;
}

