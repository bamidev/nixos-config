{ pkgs }:
let
  # All the packages that will be added to all container images to be able to inspect and manipulate
  # the containers.
  devpkgs = with pkgs; [
    bash
    coreutils
    gnugrep
    ps
    sudo
    vim
  ];
  # TODO: Add these packages afterwards as an 'overlay'
in
{
  nextcloud = import ./images/nextcloud.nix {
    inherit pkgs;
    inherit devpkgs;
  };
  stonenet-site = import ./images/stonenet-site.nix {
    inherit pkgs;
    inherit devpkgs;
  };
}
