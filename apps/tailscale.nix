{ pkgs, ... }:
let
  connectScript = pkgs.writers.writeBashBin "connect-tailscale" (with pkgs; ''
    AUTHKEY=$(${openssh}/bin/ssh 2.59.21.91 "sudo headscale preauthkeys create --user 1 --reusable --expiration 24h")
    ${tailscale}/bin/tailscale up --login-server http://2.59.21.91:8080 --authkey "AUTHKEY"
  '');
in {
  environment.systemPackages = [ connectScript ];

  services.tailscale = {
    enable = true;

    openFirewall = true;
  };
}
