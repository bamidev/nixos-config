{ lib, pkgs, ... }:
let
  monitors = import ../desktop/monitors.nix;
  startupCommands = import ../desktop/startup.nix {lib=lib; pkgs=pkgs;};
in {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      "$mod" = "SUPER";
      "$modsh" = "SUPER_SHIFT";

      "$terminal" = "${pkgs.alacritty}/bin/alacritty";
      "$menu" = "${pkgs.dmenu}/bin/dmenu_run";
      "$browser" = "${pkgs.librewolf}/bin/librewolf";

      animation = [
        "global, 1, 1, easeInSine"
        "fade, 1, 2, easeInSine"
        "windows, 1, 1, easeInSine, slide"
        "workspaces, 1, 1.2, easeInSine, slidefade"
      ];

      bezier = [
        "easeInSine, 0.12, 0, 0.39, 0"
      ];

      bind = [
        "$mod,   LEFT,  movefocus,         l"
        "$modsh, LEFT,  changegroupactive, l"
        "$mod,   RIGHT, movefocus,         r"
        "$modsh, RIGHT, changegroupactive, r"
        "$mod,   UP,    movefocus,         u"
        "$modsh, UP,    changegroupactive, u"
        "$mod,   DOWN,  movefocus,         d"
        "$modsh, DOWN,  changegroupactive, d"

        "$mod, RETURN, exec,        $terminal"
        "$mod, D,      exec,        dmenu_run"
        "$mod, G,      togglegroup,"
        "$mod, T,      exec,        $terminal"
        "$mod, Q,      exec,        $browser"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        
        "$modsh, SPACE, togglefloating"
      ];

      decoration = {
        blur = {
          enabled = true;
          size = 3;
          passes = 2;
        };

        shadow = {
          #enable = true;
          range = 4;
          render_power = 3;
        };
      };

      exec-once = startupCommands;

      general = {
        layout = "master";
      };

      input.touchpad.natural_scroll = true;

      monitor = lib.lists.forEach monitors.all (x:
        (if x.idSource == "description" then "desc:" else "") + x.id + ", " +
        "preferred, ${toString x.position.x}x${toString x.position.y}, 1"
      ) ++ [
        ", preferred, auto, 1"
      ];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };
}
