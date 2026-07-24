{
  inputs,
  lib,
  params,
  pkgs,
  ...
}:
let
  stonenet =
    (builtins.getFlake "github:bamidev/stonenet/main").nixosModules.${builtins.currentSystem}.default;
in
{
  imports = [
    ./greetd.nix
    ./libreoffice.nix
    ./postgresql.nix
    ./protonvpn.nix
    ./sway/system.nix
    ./syncthing/system.nix
    stonenet
  ];

  environment.systemPackages =
    with pkgs;
    [
      loupe
      #ladybird
      mplayer
      obs-studio
      quodlibet
      # Install texlive and texpresso from the same source as all other editor packages
    ]
    ++ (with inputs.editorPkgs; [
      texliveFull
      texpresso
    ]);

  services = {
    stonenet = {
      enable = true;
      desktop.enable = true;

      config = {
        bucket_size = 6;
      };
    };
  };
}
