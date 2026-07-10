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
    networkmanager.enable = true;
    resolvconf.enable = true;
    hostName = hostName;
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
    };
  };


  # An unaccessible dir for storing plain passwords for when there is no other way to keep things
  # declarative.
  systemd.tmpfiles.rules = [ "d /root/.password 1600 root root -" ];
}
