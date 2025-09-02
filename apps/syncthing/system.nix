{ pkgs, lib, ... }:
let
  devices = {
    "desktop" = { id = "SHBBTSU-ZI52OTS-V3BJ272-NEEBXIQ-MUVOCBV-ESAVUN4-FRAUVZR-B53BRQM"; };
    "work-laptop" = { id = "TJT3RS4-KV2A7NV-KTTA3UX-TMB2MXD-Q6DONKF-UTIBVTD-JDYGYL2-HQO76Q7"; };
    "old-work-laptop" = { id = "NYCX7JQ-6MVJLLS-G4GNLVD-QLFZ4MU-XPZWI66-HUMXO4Z-HWT4AY4-ZSDZ5QE"; };    "main-laptop" = { id = "NYCX7JQ-6MVJLLS-G4GNLVD-QLFZ4MU-XPZWI66-HUMXO4Z-HWT4AY4-ZSDZ5QE"; };
    "nas" = { id = "YQT6FYO-OGJHF6Q-WEMZWGM-QP3MJLF-F5VJ3IM-QYEEGW3-QULYD7H-ZP7OFAJ"; };
    "travel-laptop" = { id = "YNAPQOE-IJZ6OYC-FKK66MD-KKUK2F4-5HR2O5R-5GLQIKU-WMVXWM2-4BC4YA3"; };
  };
  defaultVersioning = {
    type = "staggered";
    params = {
      cleanInterval = "3600";
      keep = "5";
      maxAge = "157680000"; # About 5 years
    };
  };
  deviceNames = lib.attrsets.mapAttrsToList (name: value: name) devices;
  defaultFolder = {
    devices = deviceNames;
    ignorePerms = false;
    versioning = defaultVersioning;
  };
in {
  services.syncthing = rec {
    enable = true;

    # Give the syncthing process the users group, so that it is able to get some privileges on user
    # directories.
    group = "users";

    dataDir = "/var/lib/syncthing";
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;
    
    settings = {
      devices = devices;
      folders = {
        "Sync" = defaultFolder // {
          path = "${dataDir}/Sync";
          ignorePerms = true;
        };
        "bamilab/.password-store" = defaultFolder // {
          path = "${dataDir}/bamilab/.password-store";
        };
        "bamilab/code/private" = defaultFolder // {
          path = "${dataDir}/bamilab/code/private";
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
        "therp/Pictures" = defaultFolder // {
          path = "${dataDir}/therp/Pictures";
        };
        "therp/openvpn" = defaultFolder // {
          path = "${dataDir}/therp/openvpn";
        };
      };

      gui = {
        theme = "black";
      };

      options = {
        urAccepted = -1;
      };
    };
  };

  system.activationScripts = {
    syncthing-permissions = {
      deps = [  ];
      text = ''
        set -e

        chmod 750 /var/lib/syncthing
        chown -R syncthing:users /var/lib/syncthing/Sync
        chmod -R 775 /var/lib/syncthing/Sync
        ${pkgs.acl}/bin/setfacl -d -m g::rwx /var/lib/syncthing/Sync

        function create_file_link() {
          LINK="/home/$1/$2"
          TARGET="/var/lib/syncthing/Sync/$2"
          mkdir -p $(dirname "$LINK")
          if [ ! -e "$LINK" ] && [ -e "$TARGET" ]; then
            ln -s "$TARGET" "$LINK"
            chown "$1:users" "$LINK"
          fi
        }

        function create_folder_link() {
          USER_DIR="/var/lib/syncthing/$1"
          REAL_DIR="$USER_DIR/$2"
          mkdir -p "$REAL_DIR"
          mkdir -p $(dirname "/home/$1/$2")
          chown "$1:users" "$USER_DIR"
          chmod 775 "$USER_DIR"
          chown "$1:users" "$REAL_DIR"
          chmod 775 "$REAL_DIR"
          ${pkgs.acl}/bin/setfacl -d -m g::rwx "$REAL_DIR"
          if [ ! -e "/home/$1/$2" ]; then
            ln -s "$REAL_DIR" "/home/$1/$2"
          fi
        }

        function create_sync_link() {
          DIR="/home/$1/Sync"
          if [ ! -L "$DIR" ]; then
            if [ -e "$DIR" ]; then
              rmdir "$DIR"
            fi
            ln -s /var/lib/syncthing/Sync "$DIR"
          fi
          chown syncthing:users "$DIR"
        }

        create_folder_link bamilab .password-store
        create_folder_link bamilab code/private
        create_folder_link bamilab Documents
        create_folder_link bamilab Music
        create_folder_link bamilab Pictures
        create_folder_link therp Documents
        create_folder_link therp Pictures
        create_folder_link therp openvpn

        # Some files synced across both users and devices
        create_file_link bamilab .config/FreeTube/profiles.db
        create_file_link therp .config/FreeTube/profiles.db

        create_sync_link bamilab
        create_sync_link therp
      '';
    };
  };
}
