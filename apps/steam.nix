{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    steamcmd
    steamtui
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
  ];

  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
  };
}
