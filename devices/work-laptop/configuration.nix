{ ... }:
{
  imports = [
    ../../desktop.nix
    ../../lab/kubernetes/ca.nix
  ];

  # Enable emulation for bulding my rPi image
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  homevpn.deviceId = 1;

  nix.settings.extra-platforms = [
    "aarch64-linux"
    "arm-linux"
  ];
}
