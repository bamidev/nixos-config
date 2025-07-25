let
  config = import ../../config.nix;
  defaultVersioning = {
    type = "staggered";
    params = {
      cleanInterval = "3600";
      keep = "5";
      maxAge = "157680000"; # About 5 years
    };
  };
  devices = [ "main-laptop" "desktop" "nas" ];
  defaultFolder = {
    devices = devices;
    ignorePerms = false;
    versioning = defaultVersioning;
  };
in {
  services.syncthing = rec { 
    enable = false;

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
        "desktop" = { id = "AJG3MX7-DTBTZKM-RHR3YQN-HZMYNPT-IAREIAF-UGXRFFU-MPUHO7T-ACO5IAJ"; };
        "nas" = { id = "EIOYPAQ-2HTFA5J-V2YZE5Q-4PZH3RS-7MX2UAQ-C4I7BVT-VS6XIQR-2JKVTAR"; };
      };

      options = {
        urAccepted = -1;
      };

      folders = {
        ".config" = {
          path = if config.environmentType == "desktop" then
            "/home/${user}/.config"
          else
            "/home/${user}/synced-config";
        };
        ".password-store" = defaultFolder // {
          path = "/home/${user}/.password-store";
        };
        "Documents" = defaultFolder // {
          path = "/home/${user}/Documents";
        };
        "Pictures" = defaultFolder // {
          path = "/home/${user}/Pictures";
        };
        "Music" = defaultFolder // {
          path = "/home/${user}/Music";
        };
      };
    };
  };
}
