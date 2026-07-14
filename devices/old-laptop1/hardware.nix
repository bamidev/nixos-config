{ lib, pkgs, ... }:
{
  boot = {
    extraModulePackages = [ ];

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "ehci_pci"
        "uas"
        "usb_storage"
        "sd_mod"
      ];
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
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  hardware = rec {
    cpu.amd.updateMicrocode = enableRedistributableFirmware;
    enableRedistributableFirmware = lib.mkForce true;
  };

  # Disable WiFi radiation during sleeptime
  services = {
    cron = {
      enable = true;
      systemCronJobs = [
        "0 22 * * * root ${pkgs.util-linux}/bin/rfkill block wifi"
        "0 9 * * * root ${pkgs.util-linux}/bin/rfkill unblock wifi"
      ];
    };

    logind.lidSwitch = "ignore";
  };

  networking.hostId = "b00d1234";

  nixpkgs.hostPlatform = "x86_64-linux";

  # Make sure that when the laptop lid is closed, the system keeps running
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };
}
