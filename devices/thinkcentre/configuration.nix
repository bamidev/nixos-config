{ ... }:
{
  imports = [
    #../../lab/kubernetes/control-node.nix
    ../../lab/kubernetes/worker-node.nix
  ];

  homelab = {
    #controlNodeId = 2;
    #mainNetworkInterface = "enp1s0f1";
    deviceZpool = "main";
  };

  homevpn.deviceId = 12;
}
