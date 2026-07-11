{ config, ... }:
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
      openFirewall = true;

      vrrpInstances.my_vrrp = {
        interface = "eth0";
        priority = 1; # FIXME: Put the priority from config.nix here
        virtualIps = [{
          addr = "${config.homelab.sharedControlIp}/24";
        }];
        virtualRouterId = 77;
      };
    };

    # Kubernetes with an apiserver, controler-manager & scheduler.
    kubernetes = {
      roles = [ "master" ];
      masterAddress = config.homelab.sharedControlIp;

      apiserver.enable = true;
      controllerManager.enable = true;
      scheduler.enable = true;
    };
  };

  swapDevices = [ ];
}
