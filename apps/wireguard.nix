{ config, pkgs, ... }:
let
  port = 51820;
in {
  environment.systemPackages = with pkgs; [ wireguard-tools ];

  networking = {
    wg-quick.interfaces.wg0 = {
      address = [ "10.0.0.${toString config.myvpn.currentDeviceId}/24" ];
      autostart = true;
      generatePrivateKeyFile = true;
      privateKeyFile = "/root/.secret/wireguard-key";
      listenPort = port;

      peers = [
        # old-laptop1
        {
          publicKey = "6GswTjhFuA9xggeiw/1mzHi/DCYGBNUKFi6zd6k19zQ=";
          allowedIPs = [ "10.0.0.0/24" ];
          endpoint = "192.168.0.254:${toString port}";
        }
        # work-laptop
        {
          publicKey = "zFi+hWmuEDThYzCZOC8p+u4h9ZuNIkReI81L1ycNHVI=";
          allowedIPs = [ "10.0.0.0/24" ];
          persistentKeepalive = 25;
        }
      ];
    };

    firewall.allowedUDPPorts = [ port ];
  };
}
