{ lib, pkgs, ... }:
let
  monitors = import ../desktop/monitors.nix;
  startupCommands = import ../desktop/startup.nix {lib=lib; pkgs=pkgs;};
  theme = import ../theme.nix;
in {
  imports = [
    ./waybar.nix
  ];

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
      "$menu" = "${pkgs.dmenu}/bin/dmenu_run";
      "$browser" = "${pkgs.librewolf}/bin/librewolf";

      animation = [
        "global, 1, 1, easeInSine"
        "fade, 1, 0.35, easeInOutQuint"
        "windows, 1, 0.35, easeInOutQuint, slide"
        "workspaces, 1, 1.2, easeInSine, slidefade"
      ];

      bezier = [
        "easeInSine, 0.12, 0, 0.39, 0"
        "easeInQuart, 0.5, 0, 0.75, 0"
        "easeInOutQuint, 0.85, 0, 0.15, 1"
      ];

      bind = [
        "$mod,   LEFT,  hy3:movefocus,         l"
        "$modsh, LEFT,  changegroupactive, l"
        "$mod,   RIGHT, hy3:movefocus,         r"
        "$modsh, RIGHT, changegroupactive, r"
        "$mod,   UP,    hy3:movefocus,         u"
        "$modsh, UP,    changegroupactive, u"
        "$mod,   DOWN,  hy3:movefocus,         d"
        "$modsh, DOWN,  changegroupactive, d"

        "$mod, RETURN, exec,        $terminal"
        "$mod, B,      hy3:makegroup, h"
        "$mod, D,      exec,        dmenu_run"
        "$mod, V,      hy3:makegroup, v"
        "$mod, L,      hy3:locktab,"
        "$mod, T,      exec,        $terminal"
        "$mod, W,      exec,        $browser"

        "$modsh, E, exit"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        
        "$modsh, SPACE, togglefloating"
      ];

      binde = [
        ", XF86MonBrightnessDown, exec, sudo-brightness-down"
        ", XF86MonBrightnessUp, exec, sudo-brightness-up"
        ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -1%"
        ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +1%"
        ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
      ];

      decoration = {
        blur = {
          enabled = true;
          contrast = 0.7;
          noise = 0.15;
          size = 7;
          passes = 2;
          vibrancy = 0.2;
        };

        shadow = {
          #enable = true;
          range = 4;
          render_power = 3;
        };
      };

      exec-once = lib.lists.forEach startupCommands (x: "[workspace 1] ${x}") ++ [
        "${lib.getExe pkgs.waybar}"
      ];

      general = {
        layout = "hy3";
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
          tab_first_window = true;
        };
      };

      tabs = {
        /*col = with theme; {
          active = "rgba(${normal.blue}ff)";
          active_border = "rgba(${dim.blue}ff)";
          active_text = "rgba(${foreground}ff)";
        };*/
      };

      windowrule = [
        "opacity 0.8, class:^Alacritty$"
        "opacity 0.9, class:^Element$"
        "opacity 0.9, class:^Session$"
        "opacity 0.9, class:^signal$"
        "opacity 0.9, class:^thunderbird$"
      ];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };
}
