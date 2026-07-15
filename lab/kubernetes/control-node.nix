{
  config,
  lib,
  pkgs,
  ...
}:
let
  ports = {
    apiServer = 6443;
    etcd = {
      clientUrls = 2379;
      peerUrls = 2380;
    };
  };
  secretsPath = config.services.kubernetes.secretsPath;
in
{
  imports = [
    ./base.nix
  ];

  options.homelab.mainNetworkInterface = lib.mkOption {
    type = lib.types.str;
    default = "eth0";
  };

  config = {
    networking.firewall.allowedTCPPorts = with ports; [
      apiServer
      etcd.clientUrls
      etcd.peerUrls
    ];

    services = rec {
      # Keepalived for 'sharing' an IP address between the 3 'control nodes'.
      keepalived = {
        enable = true;
        openFirewall = true;

        vrrpInstances.my_vrrp = {
          interface = config.homelab.mainNetworkInterface;
          priority = config.homelab.controlNodeId;
          virtualIps = [
            {
              addr = "192.168.0.77/24";
            }
          ];
          virtualRouterId = 77;
        };
      };

      # Not sure why, but the service.apiserver.etcd config does not set the certificates appropriately.
      etcd = {
        peerCertFile = kubernetes.apiserver.etcd.certFile;
        peerKeyFile = kubernetes.apiserver.etcd.keyFile;
        peerTrustedCaFile = kubernetes.apiserver.etcd.caFile;
        certFile = kubernetes.apiserver.etcd.certFile;
        keyFile = kubernetes.apiserver.etcd.keyFile;
        trustedCaFile = kubernetes.apiserver.etcd.caFile;
        peerClientCertAuth = true;
      };

      # Kubernetes with an apiserver, controler-manager & scheduler.
      kubernetes = {
        roles = [ "master" ];
        # Don't use the floating ip adress for the moment
        masterAddress = config.homelab.controlNode.one.ip;
        easyCerts = false;

        apiserver = {
          enable = true;

          serviceClusterIpRange = "172.1.0.0/16";

          clientCaFile = "${secretsPath}/ca.pem";
          tlsCertFile = "${secretsPath}/apiserver.pem";
          tlsKeyFile = "${secretsPath}/apiserver-key.pem";

          etcd = {
            caFile = "${secretsPath}/ca.pem";
            certFile = "${secretsPath}/etcd.pem";
            keyFile = "${secretsPath}/etcd-key.pem";

            servers = [
              "https://${config.homelab.controlNode.one.ip}:${toString ports.etcd.clientUrls}"
              #"https://${config.homelab.controlNode.two.ip}:${toString ports.etcd.clientUrls}"
              #"https://${config.homelab.controlNode.three.ip}:${toString ports.etcd.clientUrls}"
            ];
          };

          serviceAccountKeyFile = "${secretsPath}/apiserver-account-privkey.pem";
          serviceAccountSigningKeyFile = "${secretsPath}/apiserver-account-signing-privkey.pem";
        };

        controllerManager = {
          enable = true;

          rootCaFile = "${secretsPath}/ca.pem";
          tlsCertFile = "${secretsPath}/controller-manager.pem";
          tlsKeyFile = "${secretsPath}/controller-manager-key.pem";
          kubeconfig = {
            caFile = "${secretsPath}/ca.pem";
            certFile = "${secretsPath}/controller-manager.pem";
            keyFile = "${secretsPath}/controller-manager-key.pem";
          };
        };

        proxy = {
          enable = true;

          kubeconfig = {
            caFile = "${secretsPath}/ca.pem";
            certFile = "${secretsPath}/scheduler.pem";
            keyFile = "${secretsPath}/scheduler-key.pem";
          };
        };

        scheduler = {
          enable = true;

          kubeconfig = {
            caFile = "${secretsPath}/ca.pem";
            certFile = "${secretsPath}/scheduler.pem";
            keyFile = "${secretsPath}/scheduler-key.pem";
          };
        };
      };
    };

    swapDevices = [ ];
  };
}
