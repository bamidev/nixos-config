let
  config = import ../config.nix;
in {
  services.syncthing = rec { 
    enable = true;

    group = "users";
    user = if config.environmentType == "desktop" then "bamilab" else "admin";

    dataDir = "/home/${user}/";
    configDir = "/home/${user}/.config/syncthing";
    openDefaultPorts = true;
    overrideFolders = true;
    settings = {
      devices = {
        "main-laptop" = { id = "GEPWQIW-4T6AHO3-DY2Q7FJ-BILJROF-Y7J4TA7-JGWTJ2R-TNMG5BP-5CRT2AF"; };
        "desktop" = { id = "DEVICE-ID-GOES-HERE"; };
        "nas" = { id = "DEVICE-ID-GOES-HERE"; };
      };

      options = {
        urAccepted = -1;
      };

      folders = {
        ".password-store" = {
          path = "/home/${user}/.password-store";
          devices = [ "main-laptop" "desktop" "nas" ];
          ignorePerms = false;
        };
        "Documents" = {
          path = "/home/${user}/Documents";
          devices = [ "main-laptop" "desktop" "nas" ];
          ignorePerms = true;
        };
        "Pictures" = {
          path = "/home/${user}/Pictures";
          devices = [ "main-laptop" "desktop" "nas" ];
          ignorePerms = true;
        };
      };
    };
  };
}
