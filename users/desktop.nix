{ params, pkgs, ... }:
let
  nixLocateCached = pkgs.writers.writeBashBin "nix-locate-cached" ''
    set -e
    nix run github:nix-community/nix-index-database $1
  '';
in if params.environmentType == "desktop" then {
  imports = [
    ./default.nix
    ../apps/alacritty.nix
    ../apps/chromium.nix
    ../apps/freetube.nix
    ../apps/hyprland.nix
    ../apps/librewolf.nix
    ../apps/neovim/desktop.nix
    ../apps/servo.nix
    ../apps/sway/home.nix
    ../apps/todo-txt.nix
    ../apps/wofi.nix
  ];

  accounts = {
    calendar.accounts = {
      "Personal" = {
        primary = true;

        thunderbird.enable = true;

        remote = {
          passwordCommand = "pass nextcloud/bamilab";
          type = "caldav";
          url = "http://192.168.0.254/remote.php/dav/calendars/bamilab/bamilab/";
          userName = "bamilab";
        };
      };

      "Birthdays" = {
        primary = false;

        thunderbird = {
          enable = true;
          readOnly = true;
        };

        remote = {
          passwordCommand = "pass nextcloud/bamilab";
          type = "caldav";
          url = "http://192.168.0.254/remote.php/dav/calendars/bamilab/contact_birthdays/";
          userName = "bamilab";
        };
      };
    };

    contact.accounts.Personal = {
      thunderbird.enable = true;

      remote = {
        passwordCommand = "pass nextcloud/bamilab";
        type = "carddav";
        url = "http://192.168.0.254/remote.php/dav/addressbooks/users/bamilab/contacts/";
        userName = "bamilab";
      };
    };

    email.accounts.Personal = rec {
      primary = true;
      thunderbird.enable = true;

      realName = "Danny de Jong";
      address = "danny.de.jong@pm.me";
      userName = address;

      imap = {
        host = "127.0.0.1";
        port = 1143;
        tls.useStartTls = true;
      };

      smtp = {
        host = "127.0.0.1";
        port = 1025;
        tls.useStartTls = true;
      };
    };
  };

  home.packages = [ nixLocateCached ];

  programs = {
    bash = {
      profileExtra = ''
        if [ -e ~/.init.sh ]; then
          . ~/.init.sh
        fi
      '';
      shellAliases = {
        "todo" = "todo.sh";
      };
      initExtra = ''
        eval "$(direnv hook bash)"

        if [ ! -z "$TERM" ] && [ "$TERM" != "linux" ]; then
          CURRENT_WORKSPACE=$(current-workspace)
          if [ "$PWD" == "$HOME" ] && [ -f $HOME/.here/$CURRENT_WORKSPACE ]; then
            cd $(cat $HOME/.here/$CURRENT_WORKSPACE)
          fi
        fi
      '';
    };

    element-desktop = {
      enable = true;
      settings = {
        default_theme = "dark";
      };
    };
    
    thunderbird = {
      enable = true;
      
      profiles.default = {
        isDefault = true;
      };

      /*settings = 
        let
          personal = accounts.calendar.accounts.Personal;
          birthdays = accounts.calendar.accounts.Birthdays;
          contacts = accounts.contact.accounts.Personal;
        in
        {
          "calendar.registry.personal.cache.enabled" = true;
          "calendar.registry.personal.calendar-main-default" = personal.primary;
          "calendar.registry.personal.calendar-main-in-composite" = personal.primary;
          "calendar.registry.personal.name" = "Personal";
          "calendar.registry.personal.type" = personal.remote.type;
          "calendar.registry.personal.uri" = personal.remote.url;
          "calendar.registry.personal.username" = personal.remote.userName;
          
          "calendar.registry.birthdays.cache.enabled" = true;
          "calendar.registry.birthdays.calendar-main-default" = birthdays.primary;
          "calendar.registry.birthdays.calendar-main-in-composite" = birthdays.primary;
          "calendar.registry.birthdays.name" = "Birthdays";
          "calendar.registry.birthdays.type" = birthdays.remote.type;
          "calendar.registry.birthdays.uri" = birthdays.remote.url;
          "calendar.registry.birthdays.username" = birthdays.remote.userName;

          /*
          "ldap_2.servers.Contacts.carddav.token" = "http://sabre.io/ns/sync/9";
          "ldap_2.servers.Contacts.carddav.url" = contacts.remote.url;
          "ldap_2.servers.Contacts.carddav.username" = contacts.remote.userName;
          "ldap_2.servers.Contacts.description" = "Contacts";
          "ldap_2.servers.Contacts.dirType" = "102";
          "ldap_2.servers.Contacts.filename" = "abook-1.sqlite";
          
        };*/
    };
  };
} else {
  imports = [
    ./default.nix
  ];
}
