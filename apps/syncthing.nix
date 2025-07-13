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
        "main-laptop" = { id = "YDRIMGC-TRJJZRQ-CIUQEGL-EDVFU46-VCQV5SV-WIVCSXX-455BVW5-LFDRGAN"; };
        "desktop" = { id = "DEVICE-ID-GOES-HERE"; };
        "nas" = { id = "743FG5Y-CHZCF6C-ZQCY4XX-JH2RDVX-ZH6JUYO-GHKU5QQ-LHHVF5B-OUP7TAA"; };
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
