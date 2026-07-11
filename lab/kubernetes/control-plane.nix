{ config, keepalivedPrio, ... }:
let
  kubesPort = 6443;
in
{
  imports = [
    ./base.nix
  ];

  networking.firewall.allowedTCPPorts = [ kubesPort ];

  services = {
    # Keepalived for 'sharing' an IP address between the 3 'control nodes'.
    keepalived = {
      enable = true;

      interface = "eth0";
      openFirewall = true;

      vrrpInstances.my_vrrp = {
        advertTimer = 1;
        priority = keepalivedPrio;
        virtualIps = {
          ip = "192.168.1.77/24";
        };
        virtualRouterId = 77;
      };
    };

    # Kubernetes
    kubernetes = {
      roles = [ "master" ];
      masterAddress = "control-plane.bami";

      apiserver.enable = true;
      controllerManager.enable = true;
      scheduler.enable = true;
    };
  };

  swapDevices = [ ];
}
