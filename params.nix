let
  deviceConfig = import ./device.nix;
in
import "/etc/nixos/devices/${deviceConfig.name}/params.nix"
