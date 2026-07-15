{ config, pkgs, ... }:
let
  connectScript = pkgs.writers.writeBashBin "connect-tailscale" (
    with pkgs;
    ''
      set -e
      AUTHKEY=$(${openssh}/bin/ssh -t ${config.homelab.vps.ip} "sudo headscale preauthkeys create --user 1 --reusable --expiration 24h")
      ${tailscale}/bin/tailscale up --login-server http://${config.homelab.vps.ip}:8080 --authkey "$AUTHKEY"
    ''
  );
in
{
  environment.systemPackages = [ connectScript ];

  services.tailscale = {
    enable = true;

    openFirewall = true;
  };
}
