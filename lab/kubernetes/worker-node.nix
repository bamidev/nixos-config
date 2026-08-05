{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./base.nix
  ];

  options = {
    homelab.deviceZpool = lib.mkOption {
      type = lib.types.str;
      default = "tank";
    };
  };

  config = {
    # These need to be available for Longhorn to work
    environment.systemPackages = with pkgs; [
      bash
      curl
      gawk
      gnugrep
      nfs-utils
      openiscsi
      util-linux
    ];

    security.sudo = {
      enable = true;
      extraRules = [
        {
          commands = [
            {
              command = "/run/current-system/sw/bin/ctr";
              options = [ "NOPASSWD" ];
            }
          ];

          users = [ "bamilab" ];
        }
      ];
    };

    # Kubernetes with kubelet and the proxy.
    services.kubernetes = {
      roles = [ "node" ];
    };

    system.activationScripts.createContainerdSnapshotterPool = {
      deps = [ ];
      text = ''
        SNAPSHOTTER_PATH="/var/lib/containerd/io.containerd.snapshotter.v1.zfs"
        if [ ! -e "$SNAPSHOTTER_PATH" ]; then
          ${pkgs.zfs}/bin/zfs create -o mountpoint=$SNAPSHOTTER_PATH ${config.homelab.deviceZpool}/containerd
        fi
      '';
    };

    systemd.tmpfiles.rules = [
      "d /mnt/nas 0777 root root -"
    ];

    virtualisation.containerd = {
      enable = true;
      settings = {
        # Make sure the unpack platform exists for ZFS, because otherwise we can't download images
        plugins."io.containerd.grpc.v1.cri".containerd.snapshotter = "zfs";
        plugins."io.containerd.transfer.v1.local".unpack_config = [
          {
            platform = "linux/amd64";
            snapshotter = "zfs";
          }
        ];
      };
    };

    # Mount the NAS to /mnt/nas
    fileSystems."/mnt/nas" = {
      device = "${config.homelab.nas.ip}:/exhdd";
      fsType = "nfs4";
      options = [
        "x-systemd.automount"
        "noatime"
        "nofail"
        "rw"
      ];
    };
  };
}
