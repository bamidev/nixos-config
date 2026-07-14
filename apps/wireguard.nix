{ config, pkgs, ... }:
{
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.0.0.${toString config.myvpn.currentDeviceId}/24" ];
    autostart = true;
    generatePrivateKeyFile = true;
    privateKeyFile = "/root/.secret/wireguard-key";

    peers = [
      {
        publicKey = "zFi+hWmuEDThYzCZOC8p+u4h9ZuNIkReI81L1ycNHVI=";
        allowedIPs = [ "10.0.0.0/24" ];
      }
    ];
  };
}
