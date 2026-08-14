# This laptop has about 64GB of disk space, so not a lot.
# Therefore, I just use it as a Kubernetes control node, but at the same time I use it as a NAS,
# with the an old USB HDD attached to it.
{ ... }:
{
  imports = [
    ../../lab/kubernetes/control-node.nix
    ../../lab/nas.nix
  ];

  homelab = {
    controlNodeId = 3;
    mainNetworkInterface = "enp3s0";
    enableKeepalived = false; # TODO: Debug why this device is wrongly claiming the floating ip address as well
  };

  homevpn.deviceId = 10;
}
