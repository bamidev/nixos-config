{ lib, ... }:
let
  params = import ../params.nix;
in {
  imports = [
    ./evremap.nix
    ./greetd.nix
    ./protonvpn.nix
    ./sway/system.nix
  ] ++ lib.optionals params.enableGames [
    ./steam.nix
  ];
}
