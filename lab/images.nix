{ pkgs }: {
  nextcloud = import ./images/nextcloud.nix { inherit pkgs; };
  stonenet-site = import ./images/stonenet-site.nix { inherit pkgs; };
}
