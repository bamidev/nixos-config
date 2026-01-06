{ lib, pkgs, ... }:
let
  params = import ../params.nix;
  stonenet = (builtins.getFlake "github:bamidev/stonenet/main").nixosModules.${builtins.currentSystem}.default;
in {
  imports = [
    ./greetd.nix
    ./libreoffice.nix
    ./postgresql.nix
    ./protonvpn.nix
    ./sway/system.nix
    stonenet
  ] ++ lib.optionals params.enableGames [
    ./steam.nix
  ];

  environment.systemPackages = with pkgs; [
    loupe
    ladybird
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
