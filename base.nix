{
  config,
  hostName,
  inputs,
  lib,
  params,
  pkgs,
  ...
}:

let
  theme = import ./theme.nix;

  rebuildScript = pkgs.writers.writeBashBin "rebuild-os" ''
    set -ex
    sudo nixos-rebuild switch --impure --flake /etc/nixos
  '';
  buildPiImageScript = pkgs.writers.writeBashBin "build-pi-image" ''
    set -ex
    nix build /etc/nixos#nixosConfigurations.rpi.config.system.build.sdImage --impure
  '';
in
{
  imports = [
    ./config.nix
    inputs.homeManager.nixosModules.default
    ./apps/base.nix
  ];

  system.stateVersion = "24.11";

  boot.tmp.cleanOnBoot = true;

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

  environment.systemPackages = [
    buildPiImageScript
    rebuildScript
  ];

  hardware.enableAllFirmware = lib.mkDefault false;
  hardware.enableRedistributableFirmware = lib.mkDefault false;

  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs;
      inherit params;
      nixosConfig = config;
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
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  networking = {
    networkmanager.enable = lib.mkDefault true;
    resolvconf.enable = lib.mkDefault true;
    hostName = hostName;

    # TODO: Generate this list from config.nix
    extraHosts = ''
      192.168.0.77 nextcloud.kubes
      192.168.0.77 grafana.kubes

      192.168.0.254 old-laptop-msi
      192.168.0.134 old-laptop-asus
      192.168.0.250 thinkcentre
    '';
  };

  security.polkit.enable = true;

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

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4gv0OF52jorRoiylqIcsgZRtYp1aRmR9FQD7AwTt6Q bamidev@pm.me"
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

  # An unaccessible dir for storing plain passwords for when there is no other way to keep things
  # declarative.
  systemd.tmpfiles.rules = [ "d /root/.secret 1600 root root -" ];
}
