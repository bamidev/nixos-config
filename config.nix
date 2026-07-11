{ lib, ... }:
{
  options = {
    # Some configuration parameters to configure my home-lab.
    homelab = {
      sharedControlIp = lib.mkOption {
        type = lib.types.str;
        default = "192.168.1.77";
      };

      controlNode = {
        one = {
          ip = lib.mkOption {
            type = lib.types.str;
            default = "192.168.1.2";
          };
          prio = lib.mkOption {
            type = lib.types.int;
            default = 1;
          };
        };
        two = {
          ip = lib.mkOption {
            type = lib.types.str;
            default = "192.168.1.3";
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
      };
    };
  };
}
