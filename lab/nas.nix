{ ... }:
{
  services.nfs.server = {
    enable = true;

    exports = ''
      /hdd 192.168.0.0/24(rw,sync,no_root_squash)
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
