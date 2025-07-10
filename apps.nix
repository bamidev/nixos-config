{ pkgs, ... }: {
  imports =
    [
      ./apps/neovim.nix
      ./apps/sway/system.nix
      ./apps/syncthing.nix
    ];

  services = {
    gnome.gnome-keyring.enable = true;

    # Touchpad
    libinput.enable = true;

    openvpn = {
      servers = {
        protonvpn = { config = '' config /root/nixos/openvpn/protonvpn.conf ''; };
      };
    };

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
      gitconfig.text = ''
        [alias]
        a = "add"
        b = "branch"
        c = "checkout"
        cm = "commit"
        d = "diff"
        l = "log"
        p = "pull"
        s = "status"

        [core]
        editor = "nvim"

        [push]
        autoSetupRemote = true
      '';

      "gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=Adwaita:dark
        gtk-application-prefer-dark-theme=1
      '';
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
      bash-language-server
      bc
      chromium
      # The regular dmenu is buggy (probably only on wayland), and dmenu-rs uses no absolute paths
      # in it's shell file dmenu_run. So I need to install it globally rather than keeping it's
      # installation implied.
      dmenu-rs
      element-desktop
      freetube
      gcc
      gitFull	# Pulls in `git gui`, for staging
      killall
      libreoffice
      mako
      nautilus
      nix-index
      pass
      pavucontrol
      powerline-fonts
      pre-commit
      protonmail-bridge
      protonmail-bridge-gui
      rustup
      session-desktop
      signal-desktop
      syncthing
      todo-txt-cli
      tor-browser
      vial
      w3m
      wget
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

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

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

    thunderbird = {
      enable = true;

      preferencesStatus = "locked";
      preferences = {};
    };
  };

  virtualisation.docker.enable = true;

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "text/html" = "librewolf.desktop";
      "text/plain" = "nvim.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };
  };
}

