{ config, pkgs, ... }:
let
  secretsPath = config.services.kubernetes.secretsPath;

  flannelKubeconfig = pkgs.writers.writeText "flannel.kubeconfig" ''
    apiVersion: v1
    kind: Config

    clusters:
    - name: my-cluster
      cluster:
        server: https://${config.homelab.kubesServerIp}:6443
        certificate-authority: ${secretsPath}/ca.pem

    users:
    - name: flannel
      user:
        client-certificate: ${secretsPath}/flannel.pem
        client-key: ${secretsPath}/flannel-key.pem

    contexts:
    - name: flannel@my-cluster
      context:
        cluster: my-cluster
        user: flannel
      
    current-context: flannel@my-cluster
  '';

  nodeExporterPort = 9100;
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
      nodeExporterPort
    ];
  };

  services = {
    kubernetes = {
      easyCerts = false;
      caFile = "${secretsPath}/ca.pem";

      # Install CoreDNS manually because this is deprecated
      addons.dns.enable = false;
      # I don't need the addon manager for anything.
      # When I do, keep in mind to set the KUBERNETES_MASTER & KUBECONFIG environment variables to
      # make the addon manager service work.
      addonManager.enable = false;

      masterAddress = "${config.homelab.kubesServerIp}";

      kubeconfig = {
        server = "https://${config.homelab.kubesServerIp}:6443";
        caFile = "${secretsPath}/ca.pem";
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

        clusterDns = [ "10.0.0.10" ];
        clusterDomain = "cluster.local";

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

    # Configure the client certificate that flannel uses to talk to the apiserver in a .kubeconfig
    # file
    flannel.kubeconfig = "${flannelKubeconfig}";

    prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" ];
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
        if [ -f ${secretsPath}/etcd.pem ]; then
          chown etcd:kubernetes ${secretsPath}/etcd.pem
          chown etcd:kubernetes ${secretsPath}/etcd-key.pem
          chmod 660 ${secretsPath}/etcd-key.pem
        fi
      '';
    };
  };
}
