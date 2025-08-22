{ lib, ... }:
let
  params = import ../params.nix;
in {
  imports = [
    ./greetd.nix
    ./protonvpn.nix
    ./sway/system.nix
    ./thunderbird.nix
  ] ++ lib.optionals params.enableGames [
    ./steam.nix
  ];
}
