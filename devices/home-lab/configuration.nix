{ pkgs, ... }:
{
  imports = [
    ../../apps/home-server.nix
    ../../lab/kubernetes/control-node.nix
    ../../lab/kubernetes/worker-node.nix
  ];
}
