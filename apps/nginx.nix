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
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
