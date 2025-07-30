{ pkgs, lib, ... }:
let
  config = import ../params.nix;
in {
  imports = [
    ./greetd.nix
    ./sway/system.nix
    ./thunderbird.nix
  ] ++ lib.optionals config.enableGames [
    ./steam.nix
  ];

  hardware.graphics.enable = true;

  # Disable IPv6 because it does not go through the VPN
  networking.enableIPv6 = false;

  services = {
    gnome.gnome-keyring.enable = true;

    libinput.enable = true;

    /*openvpn = {
      servers = {
        protonvpn = { config = '' config /root/nixos/openvpn/protonvpn.conf ''; };
      };
    };*/

    # Sound server
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    postgresql = {
      enable = true;
      package = pkgs.postgresql_17;

      authentication = pkgs.lib.mkOverride 10 ''
        #type database  DBuser  auth-method
        local all       all     trust
      '';

      ensureUsers = [
        {
          name = "bamilab";
          ensureClauses = {
            createdb = true;
            login = true;
          };
        }
        {
          name = "therp";
          ensureClauses = {
            createdb = true;
            login = true;
          };
        }
      ];
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    # Give Vial access to all keyboard devices
    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    etc = {
      "gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=Adwaita:dark
        gtk-application-prefer-dark-theme=1
      '';
      "openvpn/update-resolv-conf" = {
        text = ''
          #!/usr/bin/env bash
          #
          # Parses DHCP options from openvpn to update resolv.conf
          # To use set as 'up' and 'down' script in your openvpn *.conf:
          # up /etc/openvpn/update-resolv-conf
          # down /etc/openvpn/update-resolv-conf
          #
          # Used snippets of resolvconf script by Thomas Hood <jdthood@yahoo.co.uk>
          # and Chris Hanson
          # Licensed under the GNU GPL.  See /usr/share/common-licenses/GPL.
          # 07/2013 colin@daedrum.net Fixed intet name
          # 05/2006 chlauber@bnc.ch
          #
          # Example envs set from openvpn:
          # foreign_option_1='dhcp-option DNS 193.43.27.132'
          # foreign_option_2='dhcp-option DNS 193.43.27.133'
          # foreign_option_3='dhcp-option DOMAIN be.bnc.ch'
          # foreign_option_4='dhcp-option DOMAIN-SEARCH bnc.local'

          ## The 'type' builtins will look for file in $PATH variable, so we set the
          ## PATH below. You might need to directly set the path to 'resolvconf'
          ## manually if it still doesn't work, i.e.
          ## RESOLVCONF=/usr/sbin/resolvconf
          export PATH=$PATH:/sbin:/usr/sbin:/bin:/usr/bin:/run/current-system/sw/bin
          RESOLVCONF=$(type -p resolvconf)

          case $script_type in

          up)
            for optionname in $${!foreign_option_*} ; do
              option="$${!optionname}"
              echo $option
              part1=$(echo "$option" | cut -d " " -f 1)
              if [ "$part1" == "dhcp-option" ] ; then
                part2=$(echo "$option" | cut -d " " -f 2)
                part3=$(echo "$option" | cut -d " " -f 3)
                if [ "$part2" == "DNS" ] ; then
                  IF_DNS_NAMESERVERS="$IF_DNS_NAMESERVERS $part3"
                fi
                if [[ "$part2" == "DOMAIN" || "$part2" == "DOMAIN-SEARCH" ]] ; then
                  IF_DNS_SEARCH="$IF_DNS_SEARCH $part3"
                fi
              fi
            done
            R=""
            if [ "$IF_DNS_SEARCH" ]; then
              R="search "
              for DS in $IF_DNS_SEARCH ; do
                R="$${R} $DS"
              done
            R="$${R}
          "
            fi

            for NS in $IF_DNS_NAMESERVERS ; do
              R="$${R}nameserver $NS
          "
            done
            #echo -n "$R" | $RESOLVCONF -x -p -a "$${dev}"
            echo -n "$R" | $RESOLVCONF -x -a "$${dev}.inet"
            ;;
          down)
            $RESOLVCONF -d "$${dev}.inet"
            ;;
          esac

          # Workaround / jm@epiclabs.io
          # force exit with no errors. Due to an apparent conflict with the Network Manager
          # $RESOLVCONF sometimes exits with error code 6 even though it has performed the
          # action correctly and OpenVPN shuts down.
          exit 0
        '';
        mode = "0777";
      };
    };

    sessionVariables = with pkgs; rec {
      BROWSER = "${librewolf}/bin/librewolf";
      DEFAULT_BROWSER = BROWSER; # Electron based apps use this variable
      EDITOR = "${neovim}/bin/nvim";
      GTK_THEME = "Adwaita:dark";
      NIXOS_OZONE_WL = "1";
      TERMINAL = "${alacritty}/bin/alacritty";
      VISUAL = EDITOR;
    };


    shellAliases = {
      g = "git";
      gb = "git branch";
      gd = "git diff";
      gs = "git status";
    };

    systemPackages = with pkgs; [
      alacritty
      chromium
      # The regular dmenu is buggy (probably only on wayland), and dmenu-rs uses no absolute paths
      # in it's shell file dmenu_run. So I need to install it globally rather than keeping it's
      # installation implied.
      dmenu-rs
      element-desktop
      file-roller
      gcc
      gimp
      libreoffice
      mako
      nautilus
      pavucontrol
      pre-commit
      protonmail-bridge
      protonmail-bridge-gui
      rustup
      session-desktop
      signal-desktop
      todo-txt-cli
      tor-browser
      totem
      transmission_4-gtk
      vial
      wl-clipboard
      wlsunset

      # Install a bunch of python packages so that they are available to pylsp
      (python3.withPackages (python-pkgs: with python-pkgs; [
        psycopg
        psycopg2
        python-lsp-server
      
        flake8
        jedi
        pydocstyle
        pylint-odoo
        pyflakes
        pylint
      ]))
    ];
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
    dconf.profiles.user.databases = [{
      lockAll = true;
      settings = {
        "org/gnome/desktop/interface" = {
          accent-color = "blue";
          color-scheme = "prefer-dark";
          text-scaling-factor = 1.1;
        };
      };
    }];

    sway = {
      enable = true;

      package = pkgs.swayfx;
      wrapperFeatures.gtk = true;
      extraSessionCommands = ''
        # SDL:
        export SDL_VIDEODRIVER=wayland
        # QT (needs qt5.qtwayland in systemPackages):
        export QT_QPA_PLATFORM=wayland-egl
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
    };
  };

  virtualisation.docker.enable = true;

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "text/html" = "librewolf.desktop";
      "text/plain" = "neovim.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };
  };
}

