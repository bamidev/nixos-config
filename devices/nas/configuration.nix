{ config, pkgs, ... }:
{
  imports = [
    ../../apps/home-server.nix
    ../../lab/kubernetes/control-node.nix
    ../../lab/kubernetes/worker-node.nix
  ];

  config = {
    myvpn.currentDeviceId = 1;

    homelab = {
      controlNodeId = 1;
      mainNetworkInterface = "wlp2s0";
    };

    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_17;

      # Temporarily host a Postgres database on old-laptop1, that can be accessed by any kubernetes pod
      enableTCPIP = true;
      settings.listen_addresses = "*";

      authentication = pkgs.lib.mkOverride 10 ''
        #type database  DBuser  address         auth-method
        local all       all                     trust
        host  all       all     192.168.0.0/16  trust
      '';

      ensureUsers = [
        {
          name = "bamilab";
          ensureClauses = {
            createdb = true;
            login = true;
          };
        }
        {
          name = "nextcloud";
          ensureClauses = {
            login = true;
          };
        }
      ];
    };
  };
}
