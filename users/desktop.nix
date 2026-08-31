{
  nixosConfig,
  pkgs,
  ...
}:
let
  nixLocateCached = pkgs.writers.writeBashBin "nix-locate-cached" ''
    set -e
    nix run github:nix-community/nix-index-database $1
  '';

  etcdClientPort = 2379;
  kubesSecretsPath = nixosConfig.services.kubernetes.secretsPath;
in
{
  imports = [
    ./default.nix
    ../apps/alacritty.nix
    ../apps/chromium.nix
    ../apps/freetube.nix
    ../apps/hyprland.nix
    ../apps/librewolf.nix
    ../apps/neovim/desktop.nix
    ../apps/quodlibet/home.nix
    ../apps/sway/home.nix
    ../apps/todo-txt.nix
    ../apps/vikunja/home.nix
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
          url = "http://nextcloud.bamilab.space/remote.php/dav/calendars/bamilab/personal/";
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
          url = "http://nextcloud.bamilab.space/remote.php/dav/calendars/bamilab/contact_birthdays/";
          userName = "bamilab";
        };
      };

      "ToDo" = {
        primary = false;

        thunderbird = {
          enable = true;
          readOnly = true;
        };

        remote = {
          passwordCommand = "pass kubernetes/nextcloud/bamilab";
          type = "caldav";
          url = "http://vikunja.bamilab.space/dav/principals/bamilab/";
          userName = "bamilab";
        };
      };
    };

    contact.accounts.Personal = {
      thunderbird.enable = true;

      remote = {
        passwordCommand = "pass kubernetes/nextcloud/bamilab";
        type = "carddav";
        url = "http://nextcloud.bamilab.space/remote.php/dav/addressbooks/users/bamilab/contacts/";
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

  home = {
    packages =
      with pkgs;
      [
        etcd # for etcdctl
        helmfile
        kubectl
        kubectl-cnpg

        # Helm
        (wrapHelm kubernetes-helm {
          plugins = with pkgs.kubernetes-helmPlugins; [
            helm-diff
          ];
        })
        # A script that works like nix-locate, but uses a cached index so it doesn't need manual
        # indexing, which requires a lot of RAM therefore may fail on some of my devices.
      ]
      ++ [ nixLocateCached ];

    # Set up etcdctl locally to access the etcd cluster of my Kubernetes cluster.
    sessionVariables = {
      ETCDCTL_ENDPOINTS = "https://${nixosConfig.homelab.controlNode.one.vpnIp}:${toString etcdClientPort}";
      ETCDCTL_CACERT = "${kubesSecretsPath}/ca.pem";
      ETCDCTL_CERT = "${kubesSecretsPath}/admin.pem";
      ETCDCTL_KEY = "${kubesSecretsPath}/admin-key.pem";
    };
  };

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
