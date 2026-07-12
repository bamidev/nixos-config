{ config, pkgs, ... }:
let
  kubesPort = 6443;

  createCaCertScript = pkgs.writers.writeBashBin "create-ca-cert" (
    with pkgs;
    ''
      if [ ! -f /root/certs/ca.pem ]; then
        ${openssl}/bin/openssl req -x509 -new -nodes -newkey ec:/root/certs/ecparams.pem -days 3650 -out /root/certs/ca.pem -keyout /root/certs/ca-key.pem -subj "/CN=homelab-ca"
      else
        echo CA certificate /root/certs/ca.pem already exists!
      fi
    ''
  );

  createCertScript = pkgs.writers.writeBashBin "create-cert" (
    with pkgs;
    ''
      ${openssl}/bin/openssl req -new -nodes -newkey ec:/root/certs/ecparam.pem -days 3650 -out /root/certs/$1.csr -keyout /root/certs/$1-key.pem -subj "/CN=kube-$1/O=$2"
      ${openssl}/bin/openssl x509 -req -CA /root/certs/ca.pem -CAkey /root/certs/ca-key.pem -CAcreateserial -out /root/certs/$1.pem -extensions v3_ext
    ''
  );
in
{
  imports = [
    ./base.nix
  ];

  # Add a script on the control nodes to ease the creation of the CA certificate.
  environment.systemPackages = [
    createCaCertScript
    createCertScript
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

  system.activationScripts.controlNodeCerts = {
    deps = [ "ecParam" ];
    text = ''
      ${createCertScript}/bin/create-cert apiserver
    '';
  };
}
