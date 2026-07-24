{
  config,
  inputs,
  lib,
  params,
  pkgs,
  ...
}:
{
  imports = [
    ./apps/desktop.nix
    ./desktop/scripts.nix
  ];

  boot = {
    loader = {
      grub = {
        memtest86.enable = true;
      }
      // lib.attrsets.optionalAttrs (builtins.pathExists /home/bamilab/Pictures/grub.png) {
        splashImage = /home/bamilab/Pictures/grub.png;
        splashMode = "stretch";
      };
      timeout = 2;
    };

    # Completely disable the IPv6 stack in order to prevent IPv6 from being used; it is not
    # supported by my VPN.
    kernelParams = [
      "ipv6.disable=1"
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts._0xproto
  ];

  hardware.graphics.enable = true;

  home-manager.users.therp =
    { pkgs, lib, ... }:
    import ./users/therp.nix {
      pkgs = pkgs;
      lib = lib;
      inputs = inputs;
    };

  networking = {
    # Disable IPv6 because it does not go through the VPN
    enableIPv6 = false;

    firewall.allowedUDPPorts = [
      53
      67
    ];
  };

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

    upower = {
      enable = true;

      percentageCritical = 5;
      percentageLow = 15;
      usePercentageForPolicy = true;
    };
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

      "ruff.toml".text = ''
        # Exclude a variety of commonly ignored directories.
        exclude = [
            ".direnv",
            ".eggs",
            ".git",
            ".pyenv",
            ".ruff_cache",
            ".svn",
            ".venv",
            ".vscode",
            "__pypackages__",
        ]

        # Same as Black.
        line-length = 88
        indent-width = 4

        # Assume Python 3.13
        target-version = "py313"

        [lint]
        # Enable Pyflakes (`F`) and the pycodestyle (`E`) codes.
        # Unlike Flake8, Ruff doesn't enable pycodestyle warnings (`W`) or
        # McCabe complexity (`C901`) by default.
        select = ["E", "F", "I", "N", "W"]
        ignore = []

        # Allow fix for all enabled rules (when `--fix`) is provided.
        fixable = ["ALL"]
        unfixable = []

        # Allow unused variables when underscore-prefixed.
        dummy-variable-rgx = "^(_+|(_+[a-zA-Z0-9_]*[a-zA-Z0-9]+?))$"

        [lint.per-file-ignores]
        # Ruff shows F401 warnings in __init__.py, which doesn't make sense
        "__init__.py" = ["F401"]

        [format]
        # Like Black, use double quotes for strings.
        quote-style = "double"

        # Like Black, indent with spaces, rather than tabs.
        indent-style = "space"

        # Like Black, respect magic trailing commas.
        skip-magic-trailing-comma = false

        # Like Black, automatically detect the appropriate line ending.
        line-ending = "auto"

        # Enable auto-formatting of code examples in docstrings. Markdown,
        # reStructuredText code/literal blocks and doctests are all supported.
        #
        # This is currently disabled by default, but it is planned for this
        # to be opt-out in the future.
        docstring-code-format = false

        # Set the line length limit used when formatting code snippets in
        # docstrings.
        #
        # This only has an effect when the `docstring-code-format` setting is
        # enabled.
        docstring-code-line-length = "dynamic"
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

    systemPackages = with pkgs; [
      alacritty
      # The regular dmenu is buggy (probably only on wayland), and dmenu-rs uses no absolute paths
      # in it's shell file dmenu_run. So I need to install it globally rather than keeping it's
      # installation implied.
      dmenu-rs
      file-roller
      gimp
      libheif # For nautilus image preview
      mako
      nautilus
      pavucontrol
      protonmail-bridge-gui
      session-desktop
      signal-desktop
      todo-txt-cli
      tor-browser
      totem
      transmission_4-gtk
      vial
      wl-clipboard-rs
    ];
  };

  # Mount a folder from the NAS for personal files
  fileSystems."/mnt/nas" = {
    device = "${config.homevpn.nas.ip}:/hdd/personal";
    fsType = "nfs4";
    options = [
      "x-systemd.automount"
      "noatime"
      "rw"
    ];
  };

  programs = {
    dconf = {
      enable = true;

      profiles.user.databases = [
        {
          lockAll = true;
          settings = {
            "org/gnome/desktop/interface" = {
              accent-color = "blue";
              color-scheme = "prefer-dark";
              text-scaling-factor = 1.1;
            };
          };
        }
      ];
    };

    direnv.enable = true;
  };

  services.gvfs.enable = true;

  virtualisation.docker = {
    enable = true;
    extraPackages = [
      pkgs.docker-buildx
    ];
  };

  xdg = {
    mime = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "librewolf.desktop";

        "text/html" = "librewolf.desktop";
        "text/*" = "neovim.desktop";

        "video/*" = [
          "totem.desktop"
          "librewolf.desktop"
        ];

        "image/*" = [
          "org.gnome.Loupe.desktop"
          "gimp.desktop"
          "librewolf.desktop"
        ];

        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
        "x-scheme-handler/about" = "librewolf.desktop";
        "x-scheme-handler/unknown" = "librewolf.desktop";
      };
    };

    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };
}
