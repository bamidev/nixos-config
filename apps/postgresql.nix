{ pkgs, ... }: {
  services.postgresql = {
    enable = false;
    package = pkgs.postgresql_17;

    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
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
        name = "therp";
        ensureClauses = {
          createdb = true;
          login = true;
        };
      }
    ];
  };
}
