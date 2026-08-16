{ lib, ... }:
{
  imports = [
    ../../apps/lab/fail2ban.nix
    ../../apps/lab/nginx.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  homevpn.deviceId = 100;

  nix.gc = {
    dates = lib.mkForce "daily";
    options = lib.mkForce "--delete-older-than 1d";
  };
}
