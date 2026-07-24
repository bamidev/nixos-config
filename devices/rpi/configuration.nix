# This is for a Raspberry Pi 3 Model B, that I mainly use to act as a backup control node for my Kubernetes cluster.
{ inputs, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    inputs.nixos-hardware.nixosModules.raspberry-pi-3

    ../../lab/kubernetes/control-node.nix
  ];
}
