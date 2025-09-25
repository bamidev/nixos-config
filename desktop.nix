{ pkgs, ... }: {
  imports = [
    ./apps/desktop.nix
    ./desktop/scripts.nix
  ];

  hardware.graphics.enable = true;

  # Disable IPv6 because it does not go through the VPN
  networking.enableIPv6 = false;

  services = {
    gnome.gnome-keyring.enable = true;

    libinput.enable = true;

    # Sound server
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # TODO: Put into apps/postgesql.nix
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

    udisks2.enable = true;
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
    };

    pathsToLink = [
      "share/thumbnailers"
    ];

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
      gimp
      libheif # For nautilus image preview
      libheif.out
      libreoffice
      mako
      nautilus
      pavucontrol
      protonmail-bridge-gui
      rustup
      session-desktop
      signal-desktop
      todo-txt-cli
      tor-browser
      totem
      transmission_4-gtk
      vial
      wl-clipboard-rs

      # Install a bunch of python packages so that they are available to pylsp
      (python3.withPackages (python-pkgs: with python-pkgs; [
        debugpy
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

    # TODO: Put into ./apps/sway/system.nix
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

