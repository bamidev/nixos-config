{ pkgs, ... }:
let
  username = "bamilab";
  
  connectScript = pkgs.writers.writeBashBin "connect-tailscale" (
    with pkgs;
    ''
      set -ex
      AUTHKEY=$(sudo /run/current-system/sw/bin/headscale preauthkeys create --user 1 --reusable --expiration 24h")
      ${tailscale}/bin/tailscale up --login-server http://${config.homelab.vps.ip}:8080 --authkey "$AUTHKEY"
    ''
  );
in
{
  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "/run/current-system/sw/bin/headscale";
            options = [ "NOPASSWD" ];
          }
        ];
        users = [ "bamilab" ];
      }
    ];
  };

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
