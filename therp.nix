{ pkgs, ... }:

{
  imports = [
    ./therp/waft-workaround.nix
  ];

  services = {
    
    postgresql = {
      enable = true;
      package = pkgs.postgresql_17;

      authentication = pkgs.lib.mkOverride 10 ''
#type database  DBuser  auth-method
local all       all     trust
'';

      ensureUsers = [
        {
          name = "therp";
          ensureClauses = {
            createdb = true;
            login = true;
          };
        }
      ];
    };
  };
}
