{ config, ... }:
{
  imports = [
  ];

  config.myvpn.currentDeviceId = 100;

  config.boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };
}
