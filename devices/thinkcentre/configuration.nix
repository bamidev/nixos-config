{ ... }:
{
  imports = [
    ../wifi.nix
    ../../lab/kubernetes/worker-node.nix
  ];

  #homelab = {
  #  controlNodeId = 2;
  #  mainNetworkInterface = "wlp2s0";
  #  deviceZpool = "main";
  #};

  homevpn.deviceId = 12;
}
