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

      controlNode = rec {
        one = {
          ip = lib.mkOption {
            type = lib.types.str;
            default = "192.168.0.254";
          };
          prio = lib.mkOption {
            type = lib.types.int;
            default = 1;
          };
        };
        two = {
          ip = lib.mkOption {
            type = lib.types.str;
            default = "192.168.0.134";
          };
          prio = lib.mkOption {
            type = lib.types.int;
            default = 2;
          };
        };
        three = {
          ip = lib.mkOption {
            type = lib.types.str;
            default = "192.168.1.4";
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
              one
            else if controlNodeId == 2 then
              two
            else
              three;
        };
      };
    };

    homevpn = {
      main.ip = lib.mkOption {
        type = lib.types.str;
        default = "100.64.0.3";
      };
      nas.ip = lib.mkOption {
        type = lib.types.str;
        default = "100.64.0.3";
      };
    };
  };
}
