rec {
  homeManager25_05Src = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/refs/heads/release-25.05.zip";
  homeManager25_11Src = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/refs/heads/release-25.11.zip";
  homeManager25_05 = import "${homeManager25_05Src}/nixos";
  homeManager25_11 = import "${homeManager25_11Src}/nixos";
  nixpkgs25_05 = import (
    builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixos-25.05.zip"
  ) {};

  editorPkgs = nixpkgs25_05;
}
