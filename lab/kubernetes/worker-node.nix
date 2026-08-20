{
  config,
  lib,
  pkgs,
  ...
}:
let
  ports = {
    admissionWebhooks = 9443;
    dns = 53;
  };
in
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

    networking.firewall = {
      allowedTCPPorts = with ports; [
        admissionWebhooks
        dns
      ];
      allowedUDPPorts = with ports; [ dns ];
    };

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
    services = {
      kubernetes = {
        roles = [ "node" ];
      };

      # Needed to make Longhorn work on NixOS.
      # Credits: https://github.com/longhorn/longhorn/issues/2166#issuecomment-2994323945
      openiscsi = {
        enable = true;
        name = "${config.networking.hostName}-initiatorhost";
      };
    };

    system.activationScripts = {
      createContainerdSnapshotterPool = {
        deps = [ ];
        text = ''
          SNAPSHOTTER_PATH="/var/lib/containerd/io.containerd.snapshotter.v1.zfs"
          if [ ! -e "$SNAPSHOTTER_PATH" ]; then
            ${pkgs.zfs}/bin/zfs create -o mountpoint=$SNAPSHOTTER_PATH ${config.homelab.deviceZpool}/containerd
          fi
        '';
      };

      createLonghornVolume = {
        deps = [ ];
        text = with pkgs; ''
          LONGHORN_DATA_PATH=/var/lib/longhorn
          if [ ! -e /dev/zvol/tank/longhorn ]; then
            SIZE=$(${zfs}/bin/zpool list -Hp -o size tank)
            ${zfs}/bin/zfs create -V $((SIZE / 2)) -o mountpoint=none tank/longhorn
            ${e2fsprogs}/bin/mkfs.ext4 /dev/zvol/tank/longhorn
            ${util-linux}/bin/rm -rf "$LONGHORN_DATA_PATH"
            ${util-linux}/bin/mount -o noatime,discard /dev/zvol/tank/longhorn "$LONGHORN_DATA_PATH"
          fi
        '';
      };
    };

    systemd.tmpfiles.rules = [
      "d /mnt/nas 0777 root root -"
    ];

    # Needed to make Longhorn work on NixOS.
    # Credits: https://github.com/longhorn/longhorn/issues/2166#issuecomment-2994323945
    systemd.services.iscsid.serviceConfig = {
      PrivateMounts = "yes";
      BindPaths = "/run/current-system/sw/bin:/bin";
    };

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
    /*
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
    */
  };
}
