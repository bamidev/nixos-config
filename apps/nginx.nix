# Nginx is used on my VPS to route the stonenet.org website to a pod on my homelab Kubernetes cluster.
{ ... }:
{
  # We have to accept the ToS of Let's Encrypt
  security.acme.acceptTerms = true;

  services.nginx = {
    enable = true;

    virtualHosts = {
      "stonenet.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          # Access the stonenet-site server on my Kubernetes cluster on old-laptop-asus
          proxyPass = "http://172.0.0.11:30001";

          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
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
