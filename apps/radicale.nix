{ ... }: {
  networking.firewall.allowedTCPPorts = [ 5232 ];

  services.radicale = {
    enable = true;
    
    rights = {
      root = {
        user = ".+";
        collection = "";
        permissions = "R";
      };
      principal = {
        user = ".+";
        collection = "{user}";
        permissions = "RW";
      };
      calendars = {
        user = ".+";
        collection = "{user}/[^/]+";
        permissions = "rw";
      };
    };

    settings = {
      auth.type = "none";
      server.hosts = [ "0.0.0.0:5232" "[::]:5232" ];

      storage = {
        filesystem_folder = "/var/lib/radicale/collections";
      };
    };
  };
}
