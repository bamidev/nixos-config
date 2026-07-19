{ lib, ... }:
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
        type = lib.types.str;
        default = "192.168.0.77";
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

    myvpn = {
      currentDeviceId = lib.mkOption {
        type = lib.types.int;
        default = 1;
        description = "The last part of the IPv4 address for the device in the VPN.";
      };
    };
  };
}
