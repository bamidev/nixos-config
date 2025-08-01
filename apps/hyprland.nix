{ pkgs, ... }:
let
  startupCommands = import ../desktop/startup.nix;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      "$terminal" = "${pkgs.alacritty}/bin/alacritty";
      "$browser" = "${pkgs.librewolf}/bin/librewolf";

      exec-once = startupCommands ++ [
        "${pkgs.sway}/bin/swaybar"
      ];

      "$mod" = "SUPER";
      bind = [
        "$mod, LEFT, movefocus, l"
        "$mod, RIGHT, movefocus, r"
        "$mod, UP, movefocus, u"
        "$mod, DOWN, movefocus, d"

        "$mod, RETURN, exec, $terminal"
        "$mod, D, exec, dmenu_run"
        "$mod, T, exec, $terminal"
        "$mod, Q, exec, $browser"
      ];

      general = {
        layout = "master";
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };
}
