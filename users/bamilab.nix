{ ... }:
{
  imports = [
    ./default.nix
  ];

  home = {
    stateVersion = "24.11";

    file.".kube/config".source = ./bamilab/kubeconfig;

    shellAliases = {
      k = "sudo -E kubectl";
    };
  };

  programs.git.settings = {
    user = {
      name = "Bamidev";
      email = "bamidev@pm.me";
    };
  };
}
