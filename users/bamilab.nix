{ nixosConfig, ... }:
{
  imports = [
    ./default.nix
  ];

  home = {
    stateVersion = "24.11";

    file = {
      ".kube/config".text = import ./bamilab/kubeconfig.nix { host = "private.bamilab.space"; };
      ".kube/config-local".text = import ./bamilab/kubeconfig.nix {
        host = nixosConfig.homelab.kubesServerIp;
      };
    };

    shellAliases = {
      k = "sudo -E kubectl";
      kl = "sudo -E kubectl --kubeconfig=~/.kube/config-local";
    };
  };

  programs.git.settings = {
    user = {
      name = "Bamidev";
      email = "bamidev@pm.me";
    };
  };
}
