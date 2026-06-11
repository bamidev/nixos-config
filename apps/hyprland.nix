{ lib, pkgs, ... }:
let
  monitors = import ../desktop/monitors.nix;
  startupCommands = import ../desktop/startup.nix {lib=lib; pkgs=pkgs;};
  theme = import ../theme.nix;
in {
  imports = [
    ./waybar.nix
  ];

  # Put the rose-pine-hyprcursor theme in place
  home.file.".local/share/icons/rose-pine-hyprcursor" = {
    enable = true;
    recursive = true;
    source = "${pkgs.rose-pine-hyprcursor}/share/icons/rose-pine-hyprcursor";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    plugins = [
      pkgs.hyprlandPlugins.hy3
    ];

    settings = {
      "$mod" = "SUPER";
      "$modsh" = "SUPER_SHIFT";

      "$terminal" = "${pkgs.alacritty}/bin/alacritty";
      "$menu" = "wofi -n --show run";
      "$browser" = "${pkgs.librewolf}/bin/librewolf";

      animation = [
        "global, 1, 1, easeInSine"
        "fade, 1, 1, easeInSine"
        "windows, 1, 0.35, easeInSine, slide"
        "workspaces, 1, 1.2, easeInSine, slidefade"
      ];

      bezier = [
        "easeInSine, 0.12, 0, 0.39, 0"
        "easeInQuart, 0.5, 0, 0.75, 0"
        "easeInOutQuint, 0.85, 0, 0.15, 1"
      ];

      bind = [
        "$mod,   LEFT,  hy3:movefocus,     l"
        "$modsh, LEFT,  changegroupactive, l"
        "$mod,   RIGHT, hy3:movefocus,     r"
        "$modsh, RIGHT, changegroupactive, r"
        "$mod,   UP,    hy3:movefocus,     u"
        "$modsh, UP,    changegroupactive, u"
        "$mod,   DOWN,  hy3:movefocus,     d"
        "$modsh, DOWN,  changegroupactive, d"

        "$mod,   RETURN, exec,          $terminal"
        "$mod,   B,      hy3:makegroup, h, toggle"
        "$mod,   D,      exec,          $menu"
        "$mod,   V,      hy3:makegroup, v, toggle"
        "$mod,   L,      hy3:locktab,"
        "$mod,   T,      exec,          $terminal"
        "$modsh, Q,      killactive,"
        "$mod,   W,      exec,          $browser"

        "$modsh, E, exit"

        "$modsh, SPACE, togglefloating"
        
        ", PRINT, exec, ${lib.getExe pkgs.hyprshot} -m region"
        "$modsh, PRINT, exec, ${lib.getExe pkgs.hyprshot} -m window"
      ]
        ++ lib.lists.forEach (lib.range 1 9) (x: "$mod, ${toString x}, workspace, ${toString x}")
        ++ lib.lists.forEach (lib.range 1 9) (x:
          "$modsh, ${toString x}, movetoworkspacesilent, ${toString x}"
        );

      binde = [
        ", XF86MonBrightnessDown, exec, sudo-brightness-down"
        ", XF86MonBrightnessUp, exec, sudo-brightness-up"
        ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -1%"
        ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +1%"
        ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
      ];

      debug.disable_logs = false;

      decoration = {
        blur = {
          enabled = true;
          contrast = 0.4;
          noise = 0.15;
          size = 7;
          passes = 2;
          vibrancy = 0.2;
        };

        rounding = 5;

        shadow = {
          #enable = true;
          range = 4;
          render_power = 3;
        };
      };

      env = [
        "HYPRCURSOR_THEME,rose-pine-hyprcursor"
        "HYPRCURSOR_SIZE,32"
        "XCURSOR_THEME,rose-pine-hyprcursor"
        "XCURSOR_SIZE,32"
      ];

      exec-once = lib.lists.forEach startupCommands (x: "[workspace 1 silent] ${x}") ++ [
        "${lib.getExe pkgs.waybar}"
        ''swayidle -w \
            timeout 300 'swaylock -f -c ${theme.background}' \
            timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
            before-sleep 'swaylock -f -c ${theme.background}'
        ''
      ];

      general = {
        border_size = 2;
        "col.active_border" = "rgba(${theme.normal.blue}c0)";
        "col.inactive_border" = "rgba(${theme.dim.blue}c0)";
        gaps_in = 2;
        gaps_out = 7;
        layout = "hy3";
        resize_on_border = true;
      };

      input.touchpad.natural_scroll = true;

      misc.disable_hyprland_logo = true;

      monitor = lib.lists.forEach monitors.all (x:
        (if x.idSource == "description" then "desc:" else "") + x.id + ", " +
        "preferred, ${toString x.position.x}x${toString x.position.y}, 1"
      ) ++ [
        ", preferred, auto, 1"
      ];

      plugin = {
        hy3 = {
          autotile = {
            enable = true;
          };

          tab_first_window = true;
          
          tabs = {
            blur = false; # The noise doesn't look very great on tabs
            border_width = 1;
            "col.active" = "rgba(${theme.bg.blue}c0)";
            "col.active.border" = "rgba(${theme.bright.blue}c0)";
            "col.active.text" = "rgba(${theme.foreground}c0)";
            "col.inactive" = "rgba(${theme.bg.black}40)";
            "col.inactive.border" = "rgba(${theme.dim.black}40)";
            "col.inactive.text" = "rgba(${theme.foreground}40)";
            "col.locked" = "rgba(${theme.bg.green}80)";
            "col.locked.border" = "rgba(${theme.dim.green}80)";
            "col.locked.text" = "rgba(${theme.foreground}80)";
            "col.urgent" = "rgba(${theme.bg.red}c0)";
            "col.urgent.border" = "rgba(${theme.normal.red}c0)";
            "col.urgent.text" = "rgba(${theme.foreground}c0)";
            radius = 4;
          };
        };
      };

      windowrule = [
        "match:class .*, opacity 1"
        "match:class ^Alacritty$, opacity 0.85"
        "match:class ^wofi$, opacity 0.85"
        "match:class ^Element$, opacity 0.9"
        "match:class ^Session$, opacity 0.9"
        "match:class ^signal$, opacity 0.9"
        "match:class ^thunderbird$, opacity 0.9"

        "match:class ^thunderbird$, match:title ^Add Security Exception$, size 800 300, pin on"
        "match:class ^qemu$, workspace 1 silent"
      ];
    };
  };

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];
}
