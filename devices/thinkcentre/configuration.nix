{ ... }:
{
  imports = [
    ../../lab/kubernetes/control-node.nix
    ../../lab/kubernetes/worker-node.nix
  ];

  config = {
    homelab = {
      controlNodeId = 2;
      mainNetworkInterface = "wlp2s0";
    };
  };
}
