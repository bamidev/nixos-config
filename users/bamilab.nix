{ ... }:
{
  imports = [
    ./default.nix
  ];

  home = {
    stateVersion = "24.11";

    file.".kube/config".text = import ./bamilab/kubeconfig.nix { host = "172.0.0.10"; };

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
