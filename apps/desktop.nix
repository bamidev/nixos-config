{ lib, pkgs, ... }:
let
  params = import ../params.nix;
  stonenet = (builtins.getFlake "github:bamidev/stonenet/dev").nixosModules.${builtins.currentSystem}.default;
in rec {
  imports = [
    ./greetd.nix
    ./postgresql.nix
    ./protonvpn.nix
    ./sway/system.nix
    stonenet
  ] ++ lib.optionals params.enableGames [
    ./steam.nix
  ];

  environment.systemPackages = with pkgs; [
    loupe
    mplayer
    obs-studio
    texliveSmall
    quodlibet
  ];

  services.stonenet = {
    enable = true;
    desktop.enable = true;

    config = {
      bucket_size = 6;
    };
  };

}
