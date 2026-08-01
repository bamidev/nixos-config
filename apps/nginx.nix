# Nginx is used on my VPS to route the stonenet.org website to a pod on my homelab Kubernetes
# cluster.
{ config, ... }:
let
  stonenetSitePort = 30001;
in
{
  # We have to accept the ToS of Let's Encrypt
  security.acme.acceptTerms = true;

  services.nginx = {
    enable = true;

    upstreams.kubes = {
      servers = {
        "${config.homelab.controlNode.one.vpnIp}:${toString stonenetSitePort}" = { };
        #"${config.homelab.controlNode.two.vpnIp}:${toString stonenetSitePort}" = { };
        #"${config.homelab.controlNode.three.vpnIp}:${toString stonenetSitePort}" = { };
      };

      # Sticky session type of load balancing:
      extraConfig = ''
        ip_hash;
      '';
    };

    virtualHosts = {
      "stonenet.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          # Access the stonenet-site server on my Kubernetes cluster through old-laptop-asus
          proxyPass = "http://kubes";

          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
