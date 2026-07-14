{ ... }:
{
  imports = [
    ../../desktop.nix
    ../../lab/kubernetes/ca.nix
    #../../lab/kubernetes/control-node.nix
  ];

  config.myvpn.currentDeviceId = 1;
}
