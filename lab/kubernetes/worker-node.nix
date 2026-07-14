{ config, ... }:
let
  secretsPath = config.services.kubernetes.secretsPath;
in {
  imports = [
    ./base.nix
  ];

  # Kubernetes with kubelet and the proxy.
  services.kubernetes = {
    roles = [ "node" ];

    kubelet = {
      enable = true;

      kubeconfig = {
        caFile = "${secretsPath}/ca.pem";
        certFile = "${secretsPath}/kubelet.pem";
        keyFile = "${secretsPath}/kubelet-key.pem";
      };
    };
  };

  # Mount the NAS to just /mnt
  fileSystems."/mnt" = {
    device = "${config.homelab.nas.ip}:/var/nas";
    fsType = "nfs4";
    options = [
      "x-systemd.automount"
      "noatime"
      "rw"
    ];
  };
}
