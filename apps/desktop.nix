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
      alacritty
      # The regular dmenu is buggy (probably only on wayland), and dmenu-rs uses absolute paths
      # in it's shell file dmenu_run. So I need to install it globally rather than keeping it's
      # installation implied.
      dmenu-rs
      file-roller
      gimp
      gparted
      libheif # For nautilus image preview
      loupe
      mako
      mplayer
      nautilus
      obs-studio
      pavucontrol
      protonmail-bridge-gui
      session-desktop
      signal-desktop
      super-productivity
      todo-txt-cli
      tor-browser
      totem
      transmission_4-gtk
      vial
      vikunja-desktop
      wl-clipboard-rs
      quodlibet
    ]
    # Install texlive and texpresso from the same source as all other editor packages
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
