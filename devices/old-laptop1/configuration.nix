{ config, ... }:
{
  imports = [
    ../../apps/home-server.nix
    ../../lab/kubernetes/control-node.nix
    ../../lab/kubernetes/worker-node.nix
  ];

  config.homelab = {
    controlNodeId = 1;
    mainNetworkInterface = "wlp2s0";
  };
}
