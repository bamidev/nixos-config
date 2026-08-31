{ lib, pkgs, ... }:
{
  home.file.".local/share/applications/vikunja.desktop".text = ''
    [Desktop Entry]
    Name=Vikunja
    GenericName=Todo App
    Comment=Manage todo items
    Exec=${lib.getExe pkgs.vikunja-desktop} %U
    Type=Application
    Keywords=vikunja;todo;
    Icon=vikunja
    Categories=Utility;
    MimeType=x-scheme-handler/vikunja-desktop;
  '';
}
