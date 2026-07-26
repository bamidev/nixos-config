{ pkgs, ... }:
{
  home = {
    stateVersion = "24.11";

    file.".kube/config".source = ./bamilab/kubeconfig;

    packages = with pkgs; [
      kubectl
      kubectl-cnpg
    ];
  };

  programs.git.settings = {
    user = {
      name = "Bamidev";
      email = "bamidev@pm.me";
    };
  };
}
