{ pkgs, ... }: {
  imports = [
    ./apps/desktop.nix
    ./desktop/scripts.nix
  ];

  fonts.packages = with pkgs; [
    nerd-fonts._0xproto
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
      # The regular dmenu is buggy (probably only on wayland), and dmenu-rs uses no absolute paths
      # in it's shell file dmenu_run. So I need to install it globally rather than keeping it's
      # installation implied.
      dmenu-rs
      file-roller
      gimp
      libheif # For nautilus image preview
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
      ungoogled-chromium
      vial
      wl-clipboard-rs

      # Install a bunch of python development tools as the fallback tools for when no virtual
      # environment is used.
      (python3.withPackages (python-pkgs: with python-pkgs; [
        black
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
  };

  services.gvfs.enable = true;

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

