{
  config,
  lib,
  pkgs,
  ...
}:
let
  # All the port numbers that will be used to open up the firewall
  ports = {
    apiServer = 6443;
    etcd = {
      localClient = 2378;
      clientUrls = 2379;
      peerUrls = 2380;
    };
  };
  secretsPath = config.services.kubernetes.secretsPath;

  kubeConfig = pkgs.writers.writeText "kubeconfig" ''
    {
      "apiVersion":"v1",
      "clusters": [{
        "cluster": {
          "certificate-authority":"${secretsPath}/ca.pem",
          "server":"https://${config.homelab.kubesServerIp}:6443"
        },
        "name":"local"
      }],
      "contexts": [{
        "context":{
          "cluster": "local",
          "user":"kube-controller-manager"
        },
        "name":"local"
      }],
      "current-context": "local",
      "kind": "Config",
      "users": [{
        "name":"kube-controller-manager",
        "user": {
          "client-certificate":"${secretsPath}/controller-manager.pem",
          "client-key":"${secretsPath}/controller-manager-key.pem"
        }
      }]
    }
  '';
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
    environment = {
      systemPackages = [ pkgs.etcd ];

      sessionVariables = {
        ETCDCTL_ENDPOINTS = "http://127.0.0.1:${toString ports.etcd.localClient}";
      };
    };

    networking.firewall.allowedTCPPorts = with ports; [
      apiServer
      etcd.clientUrls
      etcd.peerUrls
    ];

    services = rec {
      # Keepalived for 'sharing' an IP address between the 3 'control nodes'.
      keepalived = {
        enable = config.homelab.enableKeepalived;
        openFirewall = true;

        vrrpInstances.my_vrrp = {
          interface = config.homelab.mainNetworkInterface;
          priority = 255 - config.homelab.controlNodeId * 10;
          virtualIps = [
            {
              addr = "192.168.0.77";
            }
          ];
          virtualRouterId = 77;
        };
      };

      # Not sure why, but the service.apiserver.etcd config does not set the certificates appropriately.
      etcd = {
        enable = true;

        name = config.networking.hostName;
        openFirewall = true;
        peerClientCertAuth = true;

        # Certificate files
        certFile = "${secretsPath}/etcd.pem";
        peerCertFile = "${secretsPath}/etcd.pem";
        peerKeyFile = "${secretsPath}/etcd-key.pem";
        peerTrustedCaFile = "${secretsPath}/ca.pem";
        keyFile = "${secretsPath}/etcd-key.pem";
        trustedCaFile = "${secretsPath}/ca.pem";

        # Use the LAN IP to advertise outselves
        advertiseClientUrls = [
          "https://${config.homelab.controlNode.current.ip}:${toString ports.etcd.clientUrls}"
        ];
        initialAdvertisePeerUrls = [
          "https://${config.homelab.controlNode.current.ip}:${toString ports.etcd.peerUrls}"
        ];
        # But listen on all IPs:
        listenClientUrls = [
          "https://0.0.0.0:${toString ports.etcd.clientUrls}"
          "http://127.0.0.1:2378" # Also listen locally without TLS for ease of use
        ];
        listenPeerUrls = [
          "https://${config.homelab.controlNode.current.ip}:${toString ports.etcd.peerUrls}"
        ];
        initialCluster = [
          "old-laptop-asus=https://${config.homelab.controlNode.one.ip}:${toString ports.etcd.peerUrls}"
          "thinkcentre=https://${config.homelab.controlNode.two.ip}:${toString ports.etcd.peerUrls}"
          "old-laptop-msi=https://${config.homelab.controlNode.three.ip}:${toString ports.etcd.peerUrls}"
        ];

        initialClusterState = if config.homelab.controlNodeId == 1 then "new" else "existing";
      };

      # Kubernetes with an apiserver, controler-manager & scheduler.
      kubernetes = {
        roles = [ "master" ];

        apiserver = {
          enable = true;

          allowPrivileged = true; # Needed for Longhorn
          kubeletClientCaFile = "${secretsPath}/ca.pem";
          kubeletClientCertFile = "${secretsPath}/apiserver.pem";
          kubeletClientKeyFile = "${secretsPath}/apiserver-key.pem";
          serviceAccountKeyFile = "${secretsPath}/apiserver-account-pubkey.pem";
          serviceAccountSigningKeyFile = "${secretsPath}/apiserver-account-privkey.pem";

          clientCaFile = "${secretsPath}/ca.pem";
          tlsCertFile = "${secretsPath}/apiserver.pem";
          tlsKeyFile = "${secretsPath}/apiserver-key.pem";

          etcd = {
            caFile = "${secretsPath}/ca.pem";
            certFile = "${secretsPath}/apiserver.pem";
            keyFile = "${secretsPath}/apiserver-key.pem";

            servers = [
              "https://${config.homelab.controlNode.one.ip}:${toString ports.etcd.clientUrls}"
              "https://${config.homelab.controlNode.two.ip}:${toString ports.etcd.clientUrls}"
              "https://${config.homelab.controlNode.three.ip}:${toString ports.etcd.clientUrls}"
            ];
          };
        };

        controllerManager = {
          enable = true;

          serviceAccountKeyFile = "${secretsPath}/apiserver-account-privkey.pem";

          rootCaFile = "${secretsPath}/ca.pem";
          tlsCertFile = "${secretsPath}/controller-manager.pem";
          tlsKeyFile = "${secretsPath}/controller-manager-key.pem";
          kubeconfig = {
            server = "https://${config.homelab.kubesServerIp}:6443";
            caFile = "${secretsPath}/ca.pem";
            certFile = "${secretsPath}/controller-manager.pem";
            keyFile = "${secretsPath}/controller-manager-key.pem";
          };

          extraOpts = ''
            --authentication-kubeconfig=${kubeConfig} --authorization-kubeconfig=${kubeConfig} \
            --requestheader-client-ca-file=${secretsPath}/ca.pem
          '';
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
