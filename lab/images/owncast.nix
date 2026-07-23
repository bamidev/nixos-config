# The container image for Owncast.
{ pkgs, ... }:
let
  entrypointScript = pkgs.writers.writeBashBin "entrypoint" ''
    ${pkgs.owncast}/bin/owncast -webserverport 8080 -adminpassword $ADMIN_PASSWORD
  '';
in
pkgs.dockerTools.buildLayeredImage {
  name = "owncast";

  config = {
    Cmd = [
      "${entrypointScript}/bin/entrypoint"
    ];
    ExposedPorts = {
      "8080/tcp" = { };
    };
  };
}
