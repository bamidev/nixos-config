# WireGuard is set up using wg-quick on all my devices, and they route their traffic via a
# publically accessible VPS, so that I can reach any device of my network from anywhere.

{
  config,
  hostName,
  lib,
  pkgs,
  self,
  ...
}:
let
  homeKeepaliveInterval = 25;
  port = 51820;
  subnet = "172.0.0";

  # The last number of each IPv4 address
  ids = {
    old-laptop-msi = 10;
    old-laptop-asus = 11;
    thinkcentre = 12;
    vps = 100;
    work-laptop = 1;
  };

  # All the IP addresses of the devices part of the VPN
  ips = builtins.mapAttrs (_: value: "${subnet}.${toString value}") ids;
in
{
  options = {
    homevpn.deviceId = lib.mkOption {
      description = "The unique id for the device that determines its IP address.";
      type = lib.types.int;
    };
  };
  config = {
    environment.systemPackages = with pkgs; [ wireguard-tools ];

    networking = {
      wg-quick.interfaces.wg0 = {
        address = [ "${subnet}.${toString config.homevpn.deviceId}/24" ];
        autostart = true;
        generatePrivateKeyFile = true;
        privateKeyFile = "/root/.secret/wireguard-key";
        listenPort = port;

        peers =
          # The VPS peer directs all the traffic to other peers according to a specific IP address
          if hostName == "vps" then
            [
              # vps
              {
                publicKey = "1U1LwQYOeOT1HOGAtWSOfxPy6055tG8/xOb2wcnXskY=";
                allowedIPs = [ "${ips.vps}/32" ];
              }
              # old-laptop-msi
              {
                publicKey = "6GswTjhFuA9xggeiw/1mzHi/DCYGBNUKFi6zd6k19zQ=";
                allowedIPs = [ "${ips.old-laptop-msi}/32" ];
                persistentKeepalive = homeKeepaliveInterval;
              }
              # old-laptop-asus
              {
                publicKey = "Biu59vkCyQnkOgMP88m8hLZf6yxTuM7CAjbnmTRPZHY=";
                allowedIPs = [ "${ips.old-laptop-asus}/32" ];
                persistentKeepalive = homeKeepaliveInterval;
              }
              # thinkcentre
              {
                publicKey = "rcizmz3S2CU2+7ElqLeWepozVWct5/UB75gOZ9zxty4=";
                allowedIPs = [ "${ips.thinkcentre}/32" ];
                persistentKeepalive = homeKeepaliveInterval;
              }
              # work-laptop
              {
                publicKey = "zFi+hWmuEDThYzCZOC8p+u4h9ZuNIkReI81L1ycNHVI=";
                allowedIPs = [ "${ips.work-laptop}/32" ];
                persistentKeepalive = homeKeepaliveInterval;
              }
            ]
          else
            # All other peers route all traffic targeted at the subnet to the VPS peer
            [
              {
                publicKey = "1U1LwQYOeOT1HOGAtWSOfxPy6055tG8/xOb2wcnXskY=";
                allowedIPs = [ "${subnet}.0/24" ];
                endpoint = "${config.homelab.vps.ip}:${toString port}";
              }
            ];
      };

      firewall.allowedUDPPorts = [ port ];
    };

    # Each peer will ping the VPS peer every hour, so that the hole will re-open in the NAS if it
    # has been closed, or the WireGuard session will re-open if it was closed down already.
    services.cron = {
      enable = true;
      systemCronJobs = [
        "0 * * * * root ${pkgs.iputils}/bin/ping -c 1 ${ips.vps}"
      ];
    };
  };
}
