# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  hostName,
  inputs,
  lib,
  params,
  pkgs,
  ...
}:

let
  theme = import ./theme.nix;
in
{
  imports = [
    inputs.homeManager.nixosModules.default
    ./apps.nix
  ]
  ++ lib.optionals (params.environmentType == "desktop") [
    ./desktop.nix
  ]
  ++ lib.optionals (params.environmentType == "nas") [
    ./nas.nix
  ];

  system.stateVersion = "24.11";

  boot = {
    tmp.cleanOnBoot = true;

    # Completely disable the IPv6 stack in order to prevent IPv6 from being used; it is not
    # supported by my VPN.
    kernelParams = [
      #"console=tty12"
      "ipv6.disable=1"
    ];

    loader = {
      grub = {
        enable = true;
        memtest86.enable = true;
      }
      // lib.attrsets.optionalAttrs (builtins.pathExists /home/bamilab/Pictures/grub.png) {
        splashImage = /home/bamilab/Pictures/grub.png;
        splashMode = "stretch";
      };
      timeout = 2;
    };
  };

  console.colors = [
    theme.dark.black
  ]
  ++ (with theme.normal; [
    red
    green
    yellow
    blue
    magenta
    cyan
    white
  ])
  ++ (with theme.bright; [
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

  i18n.defaultLocale = "en_US.UTF-8";

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

    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  networking = {
    enableIPv6 = false;
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
    resolvconf = {
      enable = true;
    };
    hostName = hostName;

    firewall.allowedUDPPorts = [
      53
      67
    ];
  };

  system.activationScripts.initExtraConfig = {
    deps = [ ];
    text = ''
      if [ ! -e /etc/xdg/extra-config ]; then
        export GIT_SSH="${pkgs.openssh}/bin/ssh"
        ${lib.getExe pkgs.git} clone https://github.com/bamidev/extra-config /etc/xdg/extra-config
        chown -R bamilab:users /etc/xdg/extra-config
      fi
    '';
  };

  time.timeZone = "Europe/Amsterdam";

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
          "wheel" # Enable ‘sudo’ for the user.
        ];
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
      };
    };
  };

  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs;
      inherit params;
    };

    # Use the `imports` feature because now the imports list of users/defaults.nix is being
    # overriden by the other files.
    users = {
      root =
        { pkgs, lib, ... }:
        import ./users/root.nix {
          pkgs = pkgs;
          lib = lib;
        };
      bamilab =
        { pkgs, lib, ... }:
        import ./users/bamilab.nix {
          pkgs = pkgs;
          lib = lib;
          inputs = inputs;
        };
    }
    // lib.attrsets.optionalAttrs (params.environmentType == "desktop") {
      therp =
        { pkgs, lib, ... }:
        import ./users/therp.nix {
          pkgs = pkgs;
          lib = lib;
          inputs = inputs;
        };
    };
  };

  security.polkit.enable = true;
}
