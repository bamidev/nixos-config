{
  services.syncthing = { 
    enable = true;

    group = "users";
    user = "bamilab";

    dataDir = "/home/bamilab/";
    configDir = "/home/bamilab/.config/syncthing";
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
          path = "/home/bamilab/.password-store";
          devices = [ "main-laptop" "desktop" "nas" ];
          ignorePerms = false;
        };
        "Documents" = {
          path = "/home/bamilab/Documents";
          devices = [ "main-laptop" "desktop" "nas" ];
          ignorePerms = true;
        };
        "Pictures" = {
          path = "/home/bamilab/Pictures";
          devices = [ "main-laptop" "desktop" "nas" ];
          ignorePerms = true;
        };
      };
    };
  };
}
