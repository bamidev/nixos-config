{ config, pkgs, ... }:
let
  port = 51820;
in
{
  environment.systemPackages = with pkgs; [ wireguard-tools ];

  networking = {
    wg-quick.interfaces.wg0 = {
      address = [ "10.0.0.?/24" ];
      autostart = true;
      generatePrivateKeyFile = true;
      privateKeyFile = "/root/.secret/wireguard-key";
      listenPort = port;

      peers = [
        # vps
        {
          publicKey = "1U1LwQYOeOT1HOGAtWSOfxPy6055tG8/xOb2wcnXskY=";
          allowedIPs = [ "10.0.0.100/32" ];
          endpoint = "2.59.21.91:${toString port}";
        }
        # old-laptop1
        {
          publicKey = "6GswTjhFuA9xggeiw/1mzHi/DCYGBNUKFi6zd6k19zQ=";
          allowedIPs = [ "10.0.0.1/32" ];
          persistentKeepalive = 25;
        }
        # work-laptop
        {
          publicKey = "zFi+hWmuEDThYzCZOC8p+u4h9ZuNIkReI81L1ycNHVI=";
          allowedIPs = [ "10.0.0.10/32" ];
          persistentKeepalive = 25;
        }
      ];
    };

    firewall.allowedUDPPorts = [ port ];
  };
}
