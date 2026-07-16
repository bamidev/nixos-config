{ config, ... }:
let
  secretsPath = config.services.kubernetes.secretsPath;
in
{
  imports = [
    ./base.nix
  ];

  # Kubernetes with kubelet and the proxy.
  services.kubernetes = {
    roles = [ "node" ];

    kubelet = {
      enable = true;

      clientCaFile = "${secretsPath}/ca.pem";
      tlsCertFile = "${secretsPath}/kubelet.pem";
      tlsKeyFile = "${secretsPath}/kubelet-key.pem";

      kubeconfig = {
        caFile = "${secretsPath}/ca.pem";
        certFile = "${secretsPath}/admin.pem";
        keyFile = "${secretsPath}/admin-key.pem";
      };

      # TODO: Change this timeout on a per-device basis
      extraConfig = {
        runtimeRequestTimeout = "15m";
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
