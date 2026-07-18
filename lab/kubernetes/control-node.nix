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

  kubeConfig = pkgs.writers.writeText "kubeconfig" ''
    {
      "apiVersion":"v1",
      "clusters": [{
        "cluster": {
          "certificate-authority":"${secretsPath}/ca.pem",
          "server":"https://${config.homelab.kubesEntryIp}:6443"
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

          kubeletClientCaFile = "${secretsPath}/ca.pem";
          kubeletClientCertFile = "${secretsPath}/admin.pem";
          kubeletClientKeyFile = "${secretsPath}/admin-key.pem";
          serviceAccountKeyFile = "${secretsPath}/apiserver-account-privkey.pem";
          serviceAccountSigningKeyFile = "${secretsPath}/apiserver-account-signing-privkey.pem";
          serviceClusterIpRange = config.service.kubernetes.clusterCidr;

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

        };

        controllerManager = {
          enable = true;

          serviceAccountKeyFile = "${secretsPath}/apiserver-account-privkey.pem";

          rootCaFile = "${secretsPath}/ca.pem";
          tlsCertFile = "${secretsPath}/controller-manager.pem";
          tlsKeyFile = "${secretsPath}/controller-manager-key.pem";
          kubeconfig = {
            server = "https://192.168.0.254:6443";
            caFile = "${secretsPath}/ca.pem";
            certFile = "${secretsPath}/controller-manager.pem";
            keyFile = "${secretsPath}/controller-manager-key.pem";
          };

          extraOpts = ''
            --authentication-kubeconfig=${kubeConfig} --authorization-kubeconfig=${kubeConfig} \
            --use-service-account-credentials=false \
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
