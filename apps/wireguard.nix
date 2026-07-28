# WireGuard is set up using wg-quick on all my devices, and they route their traffic via a
# publically accessible VPS, so that I can reach any device of my network from anywhere.

{
  config,
  hostName,
  lib,
  pkgs,
  ...
}:
let
  homeKeepaliveInterval = 10;
  port = 51820;
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
        address = [ "172.0.0.${toString config.homevpn.deviceId}/24" ];
        autostart = true;
        generatePrivateKeyFile = true;
        privateKeyFile = "/root/.secret/wireguard-key";
        listenPort = port;

        peers =
          if hostName == "vps" then
            [
              # vps
              {
                publicKey = "1U1LwQYOeOT1HOGAtWSOfxPy6055tG8/xOb2wcnXskY=";
                allowedIPs = [ "172.0.0.100/32" ];
              }
              # old-laptop-msi
              {
                publicKey = "6GswTjhFuA9xggeiw/1mzHi/DCYGBNUKFi6zd6k19zQ=";
                allowedIPs = [ "172.0.0.10/32" ];
                persistentKeepalive = homeKeepaliveInterval;
              }
              # old-laptop-asus
              {
                publicKey = "Biu59vkCyQnkOgMP88m8hLZf6yxTuM7CAjbnmTRPZHY=";
                allowedIPs = [ "172.0.0.11/32" ];
                persistentKeepalive = homeKeepaliveInterval;
              }
              # thinkcentre
              {
                publicKey = "rcizmz3S2CU2+7ElqLeWepozVWct5/UB75gOZ9zxty4=";
                allowedIPs = [ "172.0.0.12/32" ];
                persistentKeepalive = homeKeepaliveInterval;
              }
              # work-laptop
              {
                publicKey = "zFi+hWmuEDThYzCZOC8p+u4h9ZuNIkReI81L1ycNHVI=";
                allowedIPs = [ "172.0.0.1/32" ];
                persistentKeepalive = homeKeepaliveInterval;
              }
            ]
          else
            [
              # Route all packets through the VPS
              {
                publicKey = "1U1LwQYOeOT1HOGAtWSOfxPy6055tG8/xOb2wcnXskY=";
                allowedIPs = [ "172.0.0.0/24" ];
                endpoint = "${config.homelab.vps.ip}:${toString port}";
              }

            ];
      };

      firewall.allowedUDPPorts = [ port ];
    };
  };
}
