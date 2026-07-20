{ pkgs, ... }:
let
  configFile = pkgs.writers.writeText "nginx.conf" (
    with pkgs;
    ''
      user root;
      error_log /dev/stderr notice;
      worker_processes 1;

      http {
        include ${nginx}/conf/mime.types;
        default_type application/octet-stream;

        server {
          listen 80 default_server;
          listen [::]:80 default_server;
          server_name _;

          root /var/www/public; 
          index index.html;

          location / {
            try_files $uri $uri/ =404;
          }
        }
      }
    ''
  );

  stonenetSiteSrc = pkgs.fetchFromGitHub {
    owner = "bamidev";
    repo = "stonenet-site";
    rev = "82a1619d238ee9ce550b9840439fa0869e526e16";
    hash = "sha256-Fz6ag/7dE6hbmjimQ2Y4WqS4HlAw1k6FMbwloNKBggU=";
  };

  prepareFiles = pkgs.runCommand "prepare-files" { } ''
    mkdir -p $out/var/www
    cp -r ${stonenetSiteSrc}/* $out/var/www/
    (
      cd $out/var/www/
      ${pkgs.hugo}/bin/hugo build
    )
  '';

  entrypointScript = pkgs.writers.writeBashBin "entrypoint.sh" ''
    set -ex
    ${pkgs.nginx}/bin/nginx -e /dev/stderr -c "${configFile}"
  '';
in
pkgs.dockerTools.buildLayeredImage {
  name = "stonenet-site";

  contents =
    with pkgs;
    [
      bash
      coreutils
      ps
    ]
    ++ [
      configFile
      prepareFiles
    ];

  config = {
    Cmd = [
      "${entrypointScript}/bin/entrypoint.sh"
    ];
    Env = [
    ];
    ExposedPorts = {
      "8080/tcp" = { };
    };
  };
}
