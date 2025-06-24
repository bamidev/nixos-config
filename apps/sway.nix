{ pkgs, lib, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    #package = pkgs.swayfx;
    package = null;

    config = rec {
      menu = "${pkgs.dmenu}/bin/dmenu_run";
      modifier = "Mod4";

	  output = {
        eDP-1 = {
          bg = "~/Pictures/laptop-wallpaper.jpg fill";
          resolution = "1920x1080";
          position = "2000,2000";
        };
		"Ancor Communications Inc ASUS PB278 D1LMTF019074" = {
            bg = "~/Pictures/wallpaper.jpg fill";
            resolution = "2560x1440";
            position = "1680,560";
        };
        "BNQ BenQ GW3290QT H9P00939019" = {
          bg = "~/Pictures/wallpaper.jpg fill";
          resolution = "2560x1440";
          position = "1680,560";
        };
        "Eizo Nanao Corporation S2402W 68610031" = {
		  bg = "~/Pictures/wallpaper.jpg fill";
          resolution = "1920x1200";
          position = "2000,800";
        };
      };
      keybindings = lib.mkOptionDefault{
        "${modifier}+q" = "exec librewolf";
		"XF86MonBrightnessDown" = "exec sudo-brightness-down";
		"XF86MonBrightnessUp" = "exec sudo-brightness-up";
		"XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%''";
		"XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'";
		"XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";
      };
      terminal = "bash -c \"$(printenv TERMINAL)\"";
      startup = [
        # Launch applications on startup
        {command = "wlsunset -l 51.0 -L 5.4";}
        {command = "protonmail-bridge-gui";}
        {command = "thunderbird";}
        {command = "element-desktop";}
        {command = "signal-desktop --password-store=gnome-libsecret --use-tray-icon";}

        # Lock screen when idle
        {command = ''
swayidle -w \
timeout 300 'swaylock -f -c 000000' \
timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
before-sleep 'swaylock -f -c 000000'
'';}
      ];
    };

    extraConfig = ''
# Assign the applications started at startup at workspace 1 in a tabbed layout
workspace 1
workspace_layout tabbed

assign [title="Proton"] workspace 1
assign [title="Signal"] workspace 1
assign [title="Element.*"] workspace 1
assign [title=".*Mozilla Thunderbird"] workspace 1


# Some visual settings and effects
gaps outer 5

blur enable
blur_xray disable
blur_passes 10
blur_radius 3
blur_noise 1
blur_brightness 2
blur_contrast 2
blur_saturation 2
corner_radius 15
default_dim_inactive 0.05
shadows enable
shadows_on_csd enable
shadow_blur_radius 25
shadow_color #0000007F
shadow_offset 5 10
shadow_inactive_color #0000007F
'';
  };
}
