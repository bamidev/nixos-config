{ config, pkgs, ... }:
let
  secretsPath = config.services.kubernetes.secretsPath;
in
{
  imports = [
    ./base.nix
  ];

  # Allow all the possible node ports
  networking.firewall.allowedTCPPortRanges = [
    { from = 30000; to = 30000; }
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

    proxy = {
      enable = true;

      kubeconfig = {
        caFile = "${secretsPath}/ca.pem";
        certFile = "${secretsPath}/admin.pem";
        keyFile = "${secretsPath}/admin-key.pem";
      };
    };
  };

  systemd.acvtivationScripts.createContainerdSnapshotterPool = {
    deps = [ ];
    text = ''
      SNAPSHOTTER_PATH="/var/lib/containerd/io.containerd.snapshotter.v1.zfs"
      if [ ! -e "$SNAPSHOTTER_PATH" ]; then
        ${pkgs.zfs}/bin/zfs create -o mountpoint=$SNAPSHOTTER_PATH root/containerd
      fi
    '';
  };

  virtualisation.containerd = {
    enable = true;
    settings = {
      # Make sure the unpack platform exists for ZFS, because otherwise we can't download images
      plugins."io.containerd.grpc.v1.cri".containerd.snapshotter = "zfs";
      plugins."io.containerd.transfer.v1.local" = {
        unpack_config = [
          {
            platform = "linux/amd64";
            snapshotter = "zfs";
          }
        ];
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
