# This laptop has about 64GB of disk space, so not a lot.
# Therefore, I just use it as a Kubernetes control node, but at the same time I use it as a NAS,
# with the an old USB HDD attached to it.
{ pkgs, ... }:
{
  imports = [
    ../../apps/home-server.nix
    ../../lab/kubernetes/control-node.nix
    ../../lab/nas.nix
  ];

  config = {
    homelab = {
      controlNodeId = 1;
      mainNetworkInterface = "wlp2s0";
    };

    # Disable WiFi during sleeptime
    services = {
      cron = {
        enable = true;
        systemCronJobs = [
          "0 22 * * * root ${pkgs.util-linux}/bin/rfkill block wifi"
          "0 9 * * * root ${pkgs.util-linux}/bin/rfkill unblock wifi"
        ];
      };
    };
  };
}
