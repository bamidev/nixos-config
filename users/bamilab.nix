{ lib, pkgs, ... }:
{
  imports = [
    ./desktop.nix
  ];

  home.stateVersion = "24.11";

  programs.git.settings = {
    user = {
      name = "Bamidev";
      email = "bamidev@pm.me";
    };
  };
}
