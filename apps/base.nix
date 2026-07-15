{
  hostName,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./git.nix
    ./neovim/system.nix
    ./wireguard.nix
  ] ++ (lib.optionals (hostName != "vps") [
    #./tailscale.nix
  ]);

  environment.systemPackages = with pkgs; [
    bc
    git
    gnused
    jq
    lsof
    nix-index
    nixfmt
    openssh
    pass
    psmisc
    rsync
    screen
    socat
    sysstat
    w3m
    wget
  ];

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    mtr.enable = true;

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
