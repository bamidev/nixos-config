{ config, pkgs, ... }:
let
  kubesPort = 6443;

  createCaCertScript = pkgs.writers.writeBashBin "" (with pkgs; ''
    ${openssl}/bin/openssl ecparam -name secp384r1 -out /root/certs/ecparams.pem
    ${openssl}/bin/openssl req -x509 -new -nodes -newkey ec:/root/certs/ecparams.pem -days 3650 -out /root/certs/ca.pem -keyout /root/certs/ca-key.pem -subj "/CN=homelab-ca"
  '');
in
{
  imports = [
    ./base.nix
  ];

  # Add a script on the control nodes to ease the creation of the CA certificate.
  environment.systemPackages = [ createCaCertScript ];

  networking.firewall.allowedTCPPorts = [ kubesPort ];

  services = {
    # Keepalived for 'sharing' an IP address between the 3 'control nodes'.
    keepalived = {
      enable = true;
      openFirewall = true;

      vrrpInstances.my_vrrp = {
        interface = "eth0";
        priority = 1; # FIXME: Put the priority from config.nix here
        virtualIps = [
          {
            addr = "${config.homelab.sharedControlIp}/24";
          }
        ];
        virtualRouterId = 77;
      };
    };

    # Kubernetes with an apiserver, controler-manager & scheduler.
    kubernetes = {
      roles = [ "master" ];
      # Don't use the floating ip adress for the moment
      masterAddress = "192.168.0.254";
      easyCerts = false;
    };
  };

  swapDevices = [ ];
}
