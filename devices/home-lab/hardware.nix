{ lib, ... }:
{
  boot = {
    extraModulePackages = [];

    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "ehci_pci" "uas" "usb_storage" "sd_mod" ];
      kernelModules = [ "kvm-amd" ];
      systemd.enable = false;
    };

    kernelModules = [ "kvm-amd" ];  

    loader.grub = {
      enable = true;
      device = "nodev";
      efiInstallAsRemovable = true;
      efiSupport = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "hdd/root";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/E9C8-4216";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  hardware = rec {
    cpu.amd.updateMicrocode = enableRedistributableFirmware;
    enableRedistributableFirmware = lib.mkForce true;
  };

  networking = {
    hostId = "b00d1234";
    networkmanager.enable = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/2e5daa3d-08fb-4472-9abd-5bca3b05745c";
      randomEncryption.enable = true;
    }
  ];
}
