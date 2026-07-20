{ config, pkgs, ... }:
let
  connectScript = pkgs.writers.writeBashBin "connect-tailscale" (
    with pkgs;
    ''
      set -ex
      AUTHKEY=$(${openssh}/bin/ssh -t ${config.homelab.vps.ip} "sudo /run/current-system/sw/bin/headscale preauthkeys create --user 1 --reusable --expiration 24h")
      ${tailscale}/bin/tailscale up --login-server http://${config.homelab.vps.ip}:8080 --authkey "$AUTHKEY"
    ''
  );
in
{
  environment.systemPackages = [ connectScript ];

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ 41641 ];
  };

  services.tailscale = {
    enable = true;

    openFirewall = true;
  };
}
