{ config, ... }:
{
  imports = [
  ];

  config.myvpn.currentDeviceId = 100;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };
}
