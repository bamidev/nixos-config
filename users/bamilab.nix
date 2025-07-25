{ pkgs, lib, username, ... }:
{
  programs = {
    git = {
      userName = "Bamidev";
      userEmail = "bamidev@pm.me";
    };
  };

  services.syncthing =
    let
      homeDir = "/home/${username}";
    in {
      settings.folders =
        let
          defaults = import ../apps/syncthing/defaults.nix;
        in {
          ".config" = {
            path = "${homeDir}/.config";
          };
          ".password-store" = defaults.defaultFolder // {
            path = "${homeDir}/.password-store";
          };
          "Documents" = defaults.defaultFolder // {
            path = "${homeDir}/Documents";
          };
          "Pictures" = defaults.defaultFolder // {
            path = "${homeDir}/Pictures";
          };
          "Music" = defaults.defaultFolder // {
            path = "${homeDir}/Music";
          };
        };
    };
}
