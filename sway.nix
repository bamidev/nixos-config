{ config, pkgs, lib, ... }:

{
  wayland.windowManager.sway = {
    enable = true;

    config = rec {
      modifier = "Mod4";
      output = {
        eDP-1 = {
          #bg = "~/Pictures/wallpaper.jpg fill";
          resolution = "1920x1080";
          position = "2000,2000";
        };
        DP-3 = {
          #bg = "~/Pictures/wallpaper.jpg fill";
          resolution = "2560x1440";
          position = "1680,560";
        };
        HDMI-A-1 = {
          #bg = "~/Pictures/wallpaper.jpg fill";
          resolution = "2560x1440";
          position = "1680,560";
        };
      };
      keybindings = lib.mkOptionDefault{
        "${modifier}+q" = "exec librewolf";
		"XF86MonBrightnessDown" = "exec light -U 10";
		"XF86MonBrightnessUp" = "exec light -A 10";
		"XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%''";
		"XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'";
		"XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";
      };
      terminal = "konsole";
      startup = [
        # Launch applications on startup
        {command = "wlsunset -l 51.0 -L 5.4";}
        {command = "protonmail-bridge-gui";}
        {command = "thunderbird";}
        {command = "element-desktop";}
        {command = "signal-desktop --password-store=gnome-libsecret --use-tray-icon";}
      ];
    };

    # Assign the applications started at startup at workspace 1 in a tabbed layout
    extraConfig = ''
workspace 1
workspace_layout tabbed

assign [title="Proton"] workspace 1
assign [title="Signal"] workspace 1
assign [title="Element.*"] workspace 1
assign [title=".*Mozilla Thunderbird"] workspace 1
'';
  };
}
