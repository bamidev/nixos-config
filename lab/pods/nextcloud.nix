{ pkgs, ... }:
pkgs.dockerTools.buildLayeredImage {
  name = "nextcloud";
  contents = [ ];
  config.Cmd = [ "${pkgs.nextcloud}/bin/nextcloud" ];
}
