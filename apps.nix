{ params, pkgs, lib, ... }:
{
  imports = [
      ./apps/git.nix
      ./apps/neovim/system.nix
      ./apps/syncthing/system.nix
    ] ++ lib.optionals (params.environmentType == "desktop") [
      ./apps/desktop.nix
    ] ++ lib.optionals (params.environmentType == "nas") [
      ./apps/nas.nix
    ];

  environment.systemPackages = with pkgs; [
    bc
    killall
    nix-index
    openssh
    pass
    screen
    w3m
    wget
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      flags = [
        "--cmd c"
      ];
    };
  };

  services.openssh.enable = true;
}

