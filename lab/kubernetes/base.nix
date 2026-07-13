{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kubectl
  ];

  virtualisation.containerd.enable = true;

  services.kubernetes = {
    caFile = "${config.services.kubernetes.secretsPath}/ca.pem";

    # Trying to fix flannel configuration:
    kubeconfig = {
      server = "https://192.168.0.254:6443";

      caFile = "/var/lib/kubernetes/secrets/ca.pem";
      certFile = "/var/lib/kubernetes/secrets/admin.pem";
      keyFile = "/var/lib/kubernetes/secrets/admin-key.pem";
    };
  };

  system.activationScripts.installKubernetesCerts = {
    deps = [ ];
    text = ''
      function install() {
        if [ -e /home/bamilab/.certs/$1.pem ]; then
          mv -f /home/bamilab/.certs/$1.pem ${config.services.kubernetes.secretsPath}/$1.pem
        fi
      }

      install ca
      install admin
      install admin-key
      install apiserver
      install apiserver-key
      install apiserver-account-privkey
      install apiserver-account-pubkey
      install apiserver-account-signing-privkey
      install apiserver-account-signing-pubkey
      install controller-manager
      install controller-manager-key
      install etcd
      install etcd-key
      install proxy
      install proxy-key
      install scheduler
      install scheduler-key
    '';
  };
}
