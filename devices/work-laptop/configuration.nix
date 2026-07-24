{ ... }:
{
  imports = [
    ../../desktop.nix
    ../../lab/kubernetes/ca.nix
  ];

  # Enabl cross-compilation for my rPi image
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings.extra-platforms = [
    "aarch64-linux"
    "arm-linux"
  ];
}
