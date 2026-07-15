{ pkgs, ... }:
let
  username = "bamilab";
in
{
  services.headscale = {
    enable = true;

    address = "0.0.0.0";
    port = 8080;

    settings = {
      dns = {
        base_domain = "mesh.local";

        nameservers.global = [
          "9.9.9.9"
          "149.112.112.112"
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];

  systemd.services.headscale-init = {
    description = "Create the headscale user and key";

    after = [ "headscale.service" ];
    requires = [ "headscale.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
    };

    script = with pkgs; ''
      # Create the user if it does not exist yet
      if ! ${headscale}/bin/headscale users list | grep -q "${username}"; then
        ${headscale}/bin/headscale users create "${username}"
      fi
    '';
  };
}
