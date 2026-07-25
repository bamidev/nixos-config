# This laptop has about 64GB of disk space, so not a lot.
# Therefore, I just use it as a Kubernetes control node, but at the same time I use it as a NAS,
# with the an old USB HDD attached to it.
{ pkgs, ... }:
{
  imports = [
    ../wifi.nix
    ../../lab/kubernetes/control-node.nix
    ../../lab/nas.nix
    
    # TODO: Move syncthing to the Kubernetes cluster
    ../../apps/syncthing/system.nix
  ];

  config = {
    homelab = {
      controlNodeId = 1;
      mainNetworkInterface = "wlp2s0";
    };
  };
}
