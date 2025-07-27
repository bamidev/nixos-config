{ pkgs, ... }:
let
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
    enable = true;

    group = "users";

    dataDir = "/var/lib/syncthing";
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;
    
    settings = {
      devices = {
        "main-laptop" = { id = "NYCX7JQ-6MVJLLS-G4GNLVD-QLFZ4MU-XPZWI66-HUMXO4Z-HWT4AY4-ZSDZ5QE"; };
        "desktop" = { id = "AJG3MX7-DTBTZKM-RHR3YQN-HZMYNPT-IAREIAF-UGXRFFU-MPUHO7T-ACO5IAJ"; };
        "nas" = { id = "EIOYPAQ-2HTFA5J-V2YZE5Q-4PZH3RS-7MX2UAQ-C4I7BVT-VS6XIQR-2JKVTAR"; };
      };

      options = {
        urAccepted = -1;
      };

      folders = {
        /*"bamilab/.config" = {
          path = "bamilab/.config";
        };*/
        "bamilab/.password-store" = defaultFolder // {
          path = "${dataDir}/bamilab/.password-store";
        };
        "bamilab/Documents" = defaultFolder // {
          path = "${dataDir}/bamilab/Documents";
        };
        "bamilab/Pictures" = defaultFolder // {
          path = "${dataDir}/bamilab/Pictures";
        };
        "bamilab/Music" = defaultFolder // {
          path = "${dataDir}/bamilab/Music";
        };
        "therp/Documents" = defaultFolder // {
          path = "${dataDir}/therp/Documents";
        };
      };
    };
  };

  system.activationScripts = {
    syncthing-permissions = {
      deps = [  ];
      text = ''
        function create_link() {
          REAL_DIR="/var/lib/syncthing/$1/$2"
          chown "$1:users" "$REAL_DIR"
          ${pkgs.acl}/bin/setfacl -d -m g::rwx "$REAL_DIR"
          if [ ! -e ~/$2 ]; then
            ln -s "$REAL_DIR" ~/$2
          fi
        }

        create_link bamilab .password-store
        create_link bamilab Documents
        create_link bamilab Music
        create_link bamilab Pictures
        create_link therp Documents

        chmod 710 /var/lib/syncthing
      '';
    };
  };
}
