{ config, ... }:
{
  imports = [
    ./base.nix
  ];

  # Kubernetes with kubelet and the proxy.
  services.kubernetes = {
    roles = [ "node" ];
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
