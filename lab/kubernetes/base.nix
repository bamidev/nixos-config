{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kubectl
  ];

  virtualisation.containerd.enable = true;

  services.kubernetes.caFile = ../certs/ca.pem;

  system.activationScripts.ecParam = {
    deps = [ ];
    text = ''
      if [ ! -d /root/certs ]; then
        mkdir /root/certs
        chmod 1600 /root/certs
        ${pkgs.openssl}/bin/openssl ecparam -name secp384r1 -out /root/certs/ecparam.pem
      fi
    '';
  };
}
