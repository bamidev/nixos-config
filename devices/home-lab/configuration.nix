{ pkgs, ... }:
{
  imports = [
    ../../apps/home-server.nix
    ../../lab/kubernetes/control-node.nix
  ];
}
