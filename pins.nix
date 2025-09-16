rec {
  homeManager25_05Src = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
  homeManager25_05 = import "${homeManager25_05Src}/nixos";
  nixpkgs25_05Src = builtins.fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/refs/tags/25.05.tar.gz";
  nixpkgs25_05 = import nixpkgs25_05Src {};
}
