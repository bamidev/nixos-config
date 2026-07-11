{ ... }:
{
  services.nfs = {
    enable = true;

    exports = ''
      /var/nas 192.168.1.0/24()
    '';
  };

  systemd.tmpfiles.rules = [
    "d /var/nas 0777 root root -"
  ];
}
