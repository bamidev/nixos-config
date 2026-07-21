{ config, pkgs, ... }:
let
  secretsPath = config.services.kubernetes.secretsPath;

  # FIXME: Don't use the admin permissions for flannel, properly set it up some day
  flannelKubeconfig = pkgs.writers.writeText "flannel.kubeconfig" ''
    apiVersion: v1
    kind: Config

    clusters:
    - name: my-cluster
      cluster:
        server: https://${config.homelab.kubesServerIp}:6443
        certificate-authority: ${secretsPath}/ca.pem

    users:
    - name: admin
      user:
        client-certificate: ${secretsPath}/admin.pem
        client-key: ${secretsPath}/admin-key.pem

    contexts:
    - name: admin@my-cluster
      context:
        cluster: my-cluster
        user: admin
      
    current-context: admin@my-cluster
  '';
in
{
  environment.systemPackages = with pkgs; [
    containerd
    kubectl
  ];

  # Allow all the possible node ports
  networking.firewall = {
    allowedTCPPorts = [
      config.services.kubernetes.kubelet.port
    ];
    allowedTCPPortRanges = [
      {
        from = 30000;
        to = 30000;
      }
    ];
  };

  services = {
    kubernetes = {
      easyCerts = false;
      caFile = "${secretsPath}/ca.pem";

      masterAddress = "${config.homelab.kubesServerIp}";
      clusterCidr = "172.0.0.0/16";

      kubeconfig = {
        server = "https://${config.homelab.kubesServerIp}:6443";
        caFile = "${secretsPath}/ca.pem";
        #certFile = "${secretsPath}/admin.pem";
        #keyFile = "${secretsPath}/admin-key.pem";
      };

      flannel = {
        enable = true;
        openFirewallPorts = true;
      };

      kubelet = {
        enable = true;

        clientCaFile = "${secretsPath}/ca.pem";
        tlsCertFile = "${secretsPath}/kubelet.pem";
        tlsKeyFile = "${secretsPath}/kubelet-key.pem";

        kubeconfig = {
          caFile = "${secretsPath}/ca.pem";
          certFile = "${secretsPath}/kubelet.pem";
          keyFile = "${secretsPath}/kubelet-key.pem";
        };

        # TODO: Change this timeout on a per-device basis
        extraConfig = {
          runtimeRequestTimeout = "15m";
        };
      };

      proxy = {
        enable = true;

        kubeconfig = {
          caFile = "${secretsPath}/ca.pem";
          certFile = "${secretsPath}/proxy.pem";
          keyFile = "${secretsPath}/proxy-key.pem";
        };
      };
    };

    flannel = {
      kubeconfig = "${flannelKubeconfig}";
    };
  };

  system.activationScripts = {
    installKubernetesCerts = {
      deps = [ ];
      text = ''
        function install() {
          if [ -e /home/bamilab/.certs/$1.pem ]; then
            mv -f /home/bamilab/.certs/$1.pem ${secretsPath}/$1.pem
          fi
        }

        mkdir -p ${secretsPath}

        install ca
        install admin
        install admin-key
        install apiserver
        install apiserver-key
        install apiserver-account-privkey
        install apiserver-account-pubkey
        install controller-manager
        install controller-manager-key
        install etcd
        install etcd-key
        install flannel
        install flannel-key
        install kubelet
        install kubelet-key
        install proxy
        install proxy-key
        install scheduler
        install scheduler-key

        chown -R kubernetes:kubernetes ${secretsPath}
        chown bamilab:kubernetes ${secretsPath}/admin.pem
        chown bamilab:kubernetes ${secretsPath}/admin-key.pem
        chmod 660 ${secretsPath}/admin-key.pem
        chown etcd:kubernetes ${secretsPath}/etcd.pem
        chown etcd:kubernetes ${secretsPath}/etcd-key.pem
        chmod 660 ${secretsPath}/etcd-key.pem
      '';
    };
  };
}
