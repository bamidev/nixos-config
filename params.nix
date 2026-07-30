let
  deviceConfig = import ./device.nix;
in
import ./devices/${deviceConfig.name}/params.nix
