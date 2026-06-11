{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    #steamcmd
    #steam-tui
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
      "steamcmd"
    ];
  nixpkgs.config.allowUnfree = true;

  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };

    steam = {
      enable = true;
      gamescopeSession = {
        enable = true;
        args = [
          "-W 2560"
          "-H 1440"
        ];
      };
    };
  };
}
