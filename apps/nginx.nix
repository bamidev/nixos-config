{ ... }:
{
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
}
