# This laptop has about 64GB of disk space, so not a lot.
# Therefore, I just use it as a Kubernetes control node, but at the same time I use it as a NAS,
# with the an old USB HDD attached to it.
{ ... }:
{
  imports = [
    ../wifi.nix
    ../../lab/kubernetes/control-node.nix
    #../../lab/kubernetes/worker-node.nix
    ../../lab/nas.nix

    # TODO: Move syncthing to the Kubernetes cluster
    ../../apps/syncthing/system.nix
  ];

  homelab = {
    controlNodeId = 3;
    mainNetworkInterface = "wlp2s0";
    enableKeepalived = false; # This device is not receiving the VRRP packets very well.
  };

  homevpn.deviceId = 10;
}
