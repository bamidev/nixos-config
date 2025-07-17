let
  config = import ../config.nix;
  defaultVersioning = {
    type = "staggered";
    params = {
      cleanInterval = "3600";
      keep = "5";
      maxAge = "157680000"; # About 5 years
    };
  };
in {
  services.syncthing = rec { 
    enable = true;

    group = "users";
    user = if config.environmentType == "desktop" then "bamilab" else "admin";

    dataDir = "/home/${user}/";
    configDir = "/home/${user}/.config/syncthing";
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices = {
        "main-laptop" = { id = "YDRIMGC-TRJJZRQ-CIUQEGL-EDVFU46-VCQV5SV-WIVCSXX-455BVW5-LFDRGAN"; };
        #"desktop" = { id = "DEVICE-ID-GOES-HERE"; };
        "nas" = { id = "743FG5Y-CHZCF6C-ZQCY4XX-JH2RDVX-ZH6JUYO-GHKU5QQ-LHHVF5B-OUP7TAA"; };
      };

      options = {
        urAccepted = -1;
      };

      folders = {
        ".password-store" = {
          path = "/home/${user}/.password-store";
          devices = [ "main-laptop" "nas" ];
          ignorePerms = false;
          versioning = defaultVersioning;
        };
        "Documents" = {
          path = "/home/${user}/Documents";
          devices = [ "main-laptop" "nas" ];
          ignorePerms = true;
          versioning = defaultVersioning;
        };
        "Pictures" = {
          path = "/home/${user}/Pictures";
          devices = [ "main-laptop" "nas" ];
          ignorePerms = true;
          versioning = defaultVersioning;
        };
        "Music" = {
          path = "/home/${user}/Music";
          devices = [ "main-laptop" "nas" ];
          ignorePerms = true;
          versioning = defaultVersioning;
        };
      };
    };
  };
}
