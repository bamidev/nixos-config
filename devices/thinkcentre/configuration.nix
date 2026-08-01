{ ... }:
{
  imports = [
    ../../lab/kubernetes/control-node.nix
    ../../lab/kubernetes/worker-node.nix
  ];

  homelab = {
    controlNodeId = 2;
    mainNetworkInterface = "enp1s0f1";
    deviceZpool = "main";
    enableKeepalived = false; # Don't use VRRP for this device ATM because the IP address is not being correctly assigned which causes issues.
  };

  homevpn.deviceId = 12;
}
