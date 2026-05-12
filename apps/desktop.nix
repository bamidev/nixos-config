{ lib, pkgs, ... }:
let
  editorPkgs = (import ../sources.nix).editorPkgs.pkgs;
  params = import ../params.nix;
  stonenet = (builtins.getFlake "github:bamidev/stonenet/main").nixosModules.${builtins.currentSystem}.default;
in {
  imports = [
    ./greetd.nix
    ./keet.nix
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
    quodlibet
  # Install texlive and texpresso from the same source as all other editor packages
  ] ++ (with editorPkgs; [
    texliveFull
    texpresso
  ]);

  services = {
    stonenet = {
      enable = true;
      desktop.enable = true;

      config = {
        bucket_size = 6;
      };
    };

    upower = {
      enable = true;

      percentageCritical = 5;
      percentageLow = 10;
      usePercentageForPolicy = true;
    };
  };
}
