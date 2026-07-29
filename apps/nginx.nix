# Nginx is used on my VPS to route the stonenet.org website to a pod on my homelab Kubernetes
# cluster.
{ ... }:
let
  kubernetesEndpoint = "172.0.0.11";
in {
  # We have to accept the ToS of Let's Encrypt
  security.acme.acceptTerms = true;

  services.nginx = {
    enable = true;

    virtualHosts = {
      "stonenet.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          # Access the stonenet-site server on my Kubernetes cluster through old-laptop-asus
          proxyPass = "http://${kubernetesEndpoint}:30001";

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
