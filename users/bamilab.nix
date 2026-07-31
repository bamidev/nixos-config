{ nixosConfig, pkgs, ... }:
let
  etcdClientPort = 2379;
  kubesSecretsPath = nixosConfig.services.kubernetes.secretsPath;
in
{
  imports = [
    ./default.nix
  ];

  home = {
    stateVersion = "24.11";

    file.".kube/config".source = ./bamilab/kubeconfig;

    packages = with pkgs; [
      etcd # for etcdctl
      kubectl
      kubectl-cnpg
    ];

    # Set up etcdctl locally to access the etcd cluster of my Kubernetes cluster.
    sessionVariables = {
      ETCDCTL_ENDPOINTS = "https://${nixosConfig.homelab.controlNode.one.vpnIp}:${toString etcdClientPort}";
      ETCDCTL_CACERT = "${kubesSecretsPath}/ca.pem";
      ETCDCTL_CERT = "${kubesSecretsPath}/admin.pem";
      ETCDCTL_KEY = "${kubesSecretsPath}/admin-key.pem";
    };
  };

  programs.git.settings = {
    user = {
      name = "Bamidev";
      email = "bamidev@pm.me";
    };
  };
}
