{ ... }:
{
  imports = [
    ../../apps/nginx.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  homevpn.deviceId = 100;
}
