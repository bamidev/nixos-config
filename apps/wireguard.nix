{ config, lib, pkgs, ... }:
let
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

        peers = [
          # vps
          {
            publicKey = "1U1LwQYOeOT1HOGAtWSOfxPy6055tG8/xOb2wcnXskY=";
            allowedIPs = [ "172.0.0.100/32" ];
            endpoint = "${config.homelab.vps.ip}:${toString port}";
          }
          # old-laptop-msi
          {
            publicKey = "6GswTjhFuA9xggeiw/1mzHi/DCYGBNUKFi6zd6k19zQ=";
            allowedIPs = [ "172.0.0.10/32" ];
            persistentKeepalive = 25;
          }
          # old-laptop-asus
          {
            publicKey = "Biu59vkCyQnkOgMP88m8hLZf6yxTuM7CAjbnmTRPZHY=";
            allowedIPs = [ "172.0.0.11/32" ];
            persistentKeepalive = 25;
          }
          # thinkcentre
          {
            publicKey = "rcizmz3S2CU2+7ElqLeWepozVWct5/UB75gOZ9zxty4=";
            allowedIPs = [ "172.0.0.12/32" ];
            persistentKeepalive = 25;
          }
          # work-laptop
          {
            publicKey = "zFi+hWmuEDThYzCZOC8p+u4h9ZuNIkReI81L1ycNHVI=";
            allowedIPs = [ "172.0.0.1/32" ];
            persistentKeepalive = 25;
          }
        ];
      };

      firewall.allowedUDPPorts = [ port ];
    };
  };
}
