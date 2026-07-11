{ pkgs }: {
  nextcloud = import ./pods/nextcloud.nix { pkgs = pkgs; };
}
