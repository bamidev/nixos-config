{ lib, pkgs, ... }:
{
  imports = [
    ./desktop.nix
  ];

  home = {
    stateVersion = "24.11";

    file.".kube/config".source = ./bamilab/kubeconfig;

    packages = with pkgs; [
      kubectl
    ];
  };

  programs.git.settings = {
    user = {
      name = "Bamidev";
      email = "bamidev@pm.me";
    };
  };
}
