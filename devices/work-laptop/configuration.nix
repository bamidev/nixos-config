{ ... }:
{
  imports = [
    ../../desktop.nix
    ../../lab/kubernetes/ca.nix
  ];

  config.myvpn.currentDeviceId = 10;
}
