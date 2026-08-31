{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.vikunja-desktop ];

  # Register the vikunja-desktop:// scheme for the desktop app
  xdg.mime.defaultApplications."x-scheme-handler/vikunja-desktop" = "vikunja.desktop";
}
