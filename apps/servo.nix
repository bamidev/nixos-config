{ pkgs, ... }:
let
  latestPkgs = (import ../pins.nix).nixpkgsUnstable;
in {
  home.packages = [ latestPkgs.servo ];
}
