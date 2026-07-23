{
  nixosConfig,
  params,
  pkgs,
  ...
}:
let
  nixLocateCached = pkgs.writers.writeBashBin "nix-locate-cached" ''
    set -e
    nix run github:nix-community/nix-index-database $1
  '';
in
if params.environmentType == "desktop" then
  {
    imports = [
      ./default.nix
      ../apps/alacritty.nix
      ../apps/chromium.nix
      ../apps/freetube.nix
      ../apps/hyprland.nix
      ../apps/librewolf.nix
      ../apps/neovim/desktop.nix
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
            passwordCommand = "pass kubernetes/nextcloud/bamilab";
            type = "caldav";
            url = "http://192.168.0.77:30000/remote.php/dav/calendars/bamilab/personal/";
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
            passwordCommand = "pass kubernetes/nextcloud/bamilab";
            type = "caldav";
            url = "http://192.168.0.77:30000/remote.php/dav/calendars/bamilab/contact_birthdays/";
            userName = "bamilab";
          };
        };
      };

      contact.accounts.Personal = {
        thunderbird.enable = true;

        remote = {
          passwordCommand = "pass kubernetes/nextcloud/bamilab";
          type = "carddav";
          url = "http://192.168.0.77:30000/remote.php/dav/addressbooks/users/bamilab/contacts/";
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

      ssh = {
        enable = true;
        settings = {
          myvps = {
            HostName = nixosConfig.homelab.vps.ip;
            ForwardAgent = "yes";
          };

          myvps-tunnel-old-laptop-msi = {
            HostName = nixosConfig.homevpn.main.ip;
            ForwardAgent = "yes";
            ProxyJump = nixosConfig.homelab.vps.ip;
          };

          myvpn-old-laptop-msi = {
            HostName = "100.64.0.3";
            ForwardAgent = "yes";
          };

          myvpn-old-laptop-asus = {
            HostName = "old-laptop2";
            ForwardAgent = "yes";
            # TODO: Remove this line:
            ProxyJump = "myvpn-old-laptop-msi";
          };

        };
      };

      thunderbird = {
        enable = true;

        profiles.default = {
          isDefault = true;
        };

      };
    };
  }
else
  {
    imports = [
      ./default.nix
    ];
  }
