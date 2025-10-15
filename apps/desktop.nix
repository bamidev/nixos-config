{ lib, ... }:
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
}
