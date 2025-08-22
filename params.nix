let 
  deviceConfig = import ./device.nix;
in
  import "/etc/nixos/device/${deviceConfig.name}/params.nix"
