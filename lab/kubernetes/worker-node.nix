{
  config,
  lib,
  pkgs,
  ...
}:
let
  ports = {
    admissionWebhooks = 9443;
    cnpg.database = 8000;
    dns = 53;
    linstor = {
      nfs = 1000; # The NFS server used for RWX volume claims
      controllerRestApi = 3370;
      satellite = 3366;
    };
    piraeus.metrics = 8443;
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
    # The DRBD kernel module is necessary for Linstor, which is used by Piraeus Operator
    boot = {
      extraModprobeConfig = ''
        options drbd usermode_helper=disabled
      '';

      extraModulePackages = [ config.boot.kernelPackages.drbd ];

      kernelModules = [ "drbd" ];
    };

    # These need to be available for Piraeus Operator to work on the host
    environment.systemPackages = with pkgs; [
      drbd
    ];

    networking.firewall = {
      allowedTCPPorts = with ports; [
        admissionWebhooks
      ];

      interfaces.mynet = {
        allowedTCPPorts = with ports; [
          cnpg.database
          dns
          linstor.controllerRestApi
          linstor.nfs
          linstor.satellite
          piraeus.metrics
        ];
        allowedUDPPorts = with ports; [ dns ];
      };
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

    services.kubernetes.roles = [ "node" ];

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
    };

    systemd.tmpfiles.rules = [
      "d /mnt/nas 0777 root root -"
      # The Linstor Satellite pods are configured to mount this folder:
      "d /usr/src 0777 root root -"
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
