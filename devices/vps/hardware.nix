{
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
  ];

  # Use the GRUB 2 boot loader.
  boot = {
    extraModulePackages = [ ];

    initrd = {
      availableKernelModules = [
        "virtio_pci"
        "virtio_scsi"
        "ahci"
        "sd_mod"
        "sr_mod"
      ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-amd" ];

    loader.grub = {
      enable = true;
      device = "/dev/sda";
    };
  };

  environment.etc = {
    # VM provisioning fix, needed by BlackHOST KVM hypervisor during creation
    # can be removed, however will result in losing the ability for VM password reset & network reconfiguring
    fstab.mode = "0644";
    hosts.mode = "0644";
    os-release.mode = "0644";
  };

  fileSystems."/" = {
    device = "/dev/sda2";
    fsType = "ext4";
  };

  networking = {
    networkmanager.enable = lib.mkForce false;
    useDHCP = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  swapDevices = [
    { device = "/dev/sda1"; }
  ];
}
