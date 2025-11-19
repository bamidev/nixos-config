rec {
  homeManager25_05Src = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
  homeManagerUnstableSrc = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/fc68e1100ae6b2d46e3d423945121a41901eca9b.zip";
  homeManager25_05 = import "${homeManager25_05Src}/nixos";
  homeManagerUnstable = import "${homeManagerUnstableSrc}/nixos";
  nixpkgs25_05 = import (
    builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/25.05.tar.gz"
  ) {};
  # A very recent source (not actually a pin), for getting pretty up-to-date packages.
  # Watch out, this may trigger things to be recompiled fairly often.
  nixpkgsUnstable = import (
    builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/heads/master.zip"
  ) {};
}
