{ ... }:
{
  imports = [
    ./default.nix
  ];

  home = {
    stateVersion = "24.11";

    file.".kube/config".source = ./bamilab/kubeconfig;

  };

  programs.git.settings = {
    user = {
      name = "Bamidev";
      email = "bamidev@pm.me";
    };
  };
}
