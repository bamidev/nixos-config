{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [ 80 ];

  services.nextcloud = rec {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = "0.0.0.0";
    config.adminpassFile = "/root/.secret/nextcloud/admin";
    config.dbtype = "sqlite";

    extraApps = {
      inherit (package.packages.apps) bookmarks contacts calendar;
    };
    extraAppsEnable = true;

    settings = {
      trusted_domains = [ "192.168.0.254" ];
    };
  };

  /*
    system.activationScripts.nextcloud-setup.text = ''
      # Ensure user
      export PASS=$(cat /root/.secret/nextcloud/bamilab)
      echo -e $PASS\\n$PASS | ${lib.getExe config.services.nextcloud.occ} user:add bamilab || true

      ${lib.getExe config.services.nextcloud.occ} dav:create-calendar -n bamilab bamilab || true
    '';
  */

  systemd.tmpfiles.rules = [ "f /root/.secret/nextcloud/admin 600 root root -" ];
}
