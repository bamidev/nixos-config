# Nginx is used on my VPS to route the stonenet.org website to a pod on my homelab Kubernetes
# cluster.
# The connections are load-balanced over my 3 Kubernetes control nodes.
{ config, ... }:
let
  ports = {
    stonenetSite = 30001;
    owncast = 30003;
  };

  upstream = port: {
    servers = {
      "${config.homelab.controlNode.one.vpnIp}:${toString port}" = {
        # Give the first control node a lower fail_timeout, because it is generally the most
        # reliable one.
        fail_timeout = "15m";
        max_fails = 1;
      };
      "${config.homelab.controlNode.two.vpnIp}:${toString port}" = {
        fail_timeout = "1h";
        max_fails = 2;
      };
      "${config.homelab.controlNode.three.vpnIp}:${toString port}" = {
        fail_timeout = "1h";
        max_fails = 3;
      };
    };

    # Sticky session type of load balancing:
    extraConfig = ''
      ip_hash;
    '';
  };

  virtualHost = upstream: {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${upstream}";

      extraConfig = ''
        proxy_connect_timeout 10s;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
in
{
  # We have to accept the ToS of Let's Encrypt
  security.acme.acceptTerms = true;

  services.nginx = {
    enable = true;

    upstreams = {
      kubes-stonenet-site = upstream ports.stonenetSite;
      kubes-owncast = upstream ports.owncast;
    };

    virtualHosts = {
      "stonenet.org" = virtualHost "kubes-stonenet-site";
      "stream.bami.stonenet.org" = virtualHost "kubes-owncast";
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
