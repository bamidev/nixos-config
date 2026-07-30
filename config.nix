{ config, lib, ... }:
{
  options = {
    # Some configuration parameters to configure my home-lab.
    homelab = rec {
      nas.ip = lib.mkOption {
        type = lib.types.str;
        default = "192.168.0.254";
      };
      vps.ip = lib.mkOption {
        type = lib.types.str;
        default = "2.59.21.91";
      };

      kubesServerIp = lib.mkOption {
        description = "The main IP address to reach the Kubernetes cluster with";
        type = lib.types.str;
        default = "192.168.0.77";
      };

      kubesVpnServerIp = lib.mkOption {
        description = "The IP address to reach the Kubernetes cluster with over my VPN";
        type = lib.types.str;
        default = config.homevpn.main.ip;
      };

      controlNodeId = lib.mkOption {
        type = lib.types.int;
        default = 2;
      };

      controlNode = {
        one = {
          ip = lib.mkOption {
            type = lib.types.str;
            default = "192.168.0.134";
          };
          prio = lib.mkOption {
            type = lib.types.int;
            default = 1;
          };
        };
        two = {
          ip = lib.mkOption {
            type = lib.types.str;
            default = "192.168.0.148";
          };
          prio = lib.mkOption {
            type = lib.types.int;
            default = 2;
          };
        };
        three = {
          ip = lib.mkOption {
            type = lib.types.str;
            default = "192.168.0.254";
          };
          prio = lib.mkOption {
            type = lib.types.int;
            default = 3;
          };
        };

        current = lib.mkOption {
          type = lib.types.attrs;
          default =
            if controlNodeId == 1 then
              config.homelab.controlNode.one
            else if controlNodeId == 2 then
              config.homelab.controlNode.two
            else
              config.homelab.controlNode.three;
        };
      };

      workerNodes = lib.mkOption {
        description = "A list of domain names for all the available worker nodes";
        type = lib.types.listOf lib.types.attrs;
        default = [
          {
            domain = "old-laptop-asus";
            vpnIp = "172.0.0.11";
          } # The old-laptop-asus device is put on top so that deploy-image deploy to that first
          {
            domain = "old-laptop-msi";
            vpnIp = "172.0.0.10";
          }
          {
            domain = "thinkcentre";
            vpnIp = "172.0.0.12";
          }
        ];
      };
    };

    homevpn = {
      main.ip = lib.mkOption {
        type = lib.types.str;
        default = "172.0.0.11";
      };
      nas.ip = lib.mkOption {
        type = lib.types.str;
        default = "172.0.0.10";
      };
    };
  };
}
