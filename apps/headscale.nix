{ pkgs, ... }:
let
  username = "bamilab";
  secretsPath = "/var/lib/headscale/secrets";
in
{
  services.headscale = {
    enable = true;

    address = "2.59.21.91";

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

  /*systemd.services.headscale-init = {
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

      mkdir -p "${secretsPath}"
      ${headscale}/bin/headscale preauthkeys create -u "${username}" --reusable \
        > "${secretsPath}"

      chmod 600 "${secretsPath}"
    '';
  };*/
}
