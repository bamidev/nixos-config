{ lib, pkgs, ... }:
let
  params = import ../params.nix;
in {
  imports = [
    ./greetd.nix
    ./postgresql.nix
    ./protonvpn.nix
    ./sway/system.nix
  ] ++ lib.optionals params.enableGames [
    ./steam.nix
  ];

  environment.systemPackages = with pkgs; [
    mplayer
    obs-studio
    quodlibet
  ];
}
