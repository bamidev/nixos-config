{ pkgs, lib, ... }:
let
  i3status-wrapper = pkgs.writers.writeBashBin "i3status-wrapper" ''
    ${pkgs.i3status}/bin/i3status -c /etc/i3status.conf | while :
    do
      read -r LINE
      if [ "''${LINE:0:3}" == ",[{" ]; then
        TODO_COUNT=$(cat $HOME/todo.txt | wc -l)
        echo ",[{\"name\":\"todo\",\"full_text\":\"TODOs: $TODO_COUNT\"},''${LINE:2}"
      else
        echo "$LINE"
      fi
     done
  '';
  theme = import ../../theme.nix;
in {
  wayland.windowManager.sway = {
    enable = true;
    #package = pkgs.swayfx;
    package = null;

    config = rec {
      menu = "dmenu_run";
      modifier = "Mod4";

      colors = {
        background = theme.background;
        focused = {
          background = theme.dark.blue;
          border = theme.dark.blue;
          childBorder = theme.dark.blue;
          indicator = "#2e9ef4";
          text = theme.foreground;
        };
        focusedInactive = {
          background = "#5f676a";
          border = "#333333";
          childBorder = "#5f676a";
          indicator = "#484e50";
          text = "#ffffff";
        };
        placeholder = {
          background = "#0c0c0c";
          border = "#000000";
          childBorder = "#0c0c0c";
          indicator = "#000000";
          text = "#ffffff";
        };
        unfocused = {
          background = "#222222";
          border = "#333333";
          childBorder = "#222222";
          indicator = "#292d2e";
          text = "#888888";
        };
        urgent = {
          background = theme.bg.red;
          border = theme.normal.red;
          childBorder = "#900000";
          indicator = "#900000";
          text = theme.foreground;
        };
      };

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
        { command = "wlsunset -l 51.0 -L 5.4 -t 3500"; }
        { command = "protonmail-bridge-gui"; }
        { command = "thunderbird"; }
        { command = "element-desktop --hidden"; }
        { command = "session-desktop"; }
        { command = "signal-desktop --password-store=\"gnome-libsecret\" --use-tray-icon"; }

        # Lock screen when idle
        {
          command = ''
            swayidle -w \
            timeout 300 'swaylock -f -c 000000' \
            timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
            before-sleep 'swaylock -f -c 000000'
            '';
        }
      ];

      bars = [
        {
          colors = {
            background = "${theme.background}ff";
            statusline = theme.foreground;
            separator = theme.bg.white;
          };
          command = "${pkgs.sway}/bin/swaybar";
          statusCommand = "${i3status-wrapper}/bin/i3status-wrapper";
          position = "top";
          trayOutput = "*";
          workspaceButtons = true;
          workspaceNumbers = true;
        }
      ];
    };

    extraConfig = ''
      # Cool transparant windows for certain apps
      for_window [app_id="Alacritty"] opacity 0.85
      for_window [app_id="Element"] opacity 0.9
      for_window [app_id="Session"] opacity 0.9
      for_window [app_id="signal"] opacity 0.9
      for_window [app_id="thunderbird"] opacity 0.9

      # Assign the applications started at startup at workspace 1 in a tabbed layout
      workspace 1
      workspace_layout tabbed

      assign [title="Proton"] workspace 1
      assign [app_id="signal"] workspace 1
      assign [app_id="Element"] workspace 1
      assign [app_id="Session"] workspace 1
      assign [app_id="thunderbird"] workspace 1


      # Some visual settings and effects
      gaps outer 7

      blur enable
      blur_xray disable
      blur_passes 2
      blur_radius 7
      blur_noise 0.2
      blur_brightness 1
      blur_contrast 0.7
      blur_saturation 1.2
      corner_radius 5
      shadows enable
      shadows_on_csd enable
      shadow_blur_radius 25
      shadow_color #0000007F
      shadow_offset 5 10
      shadow_inactive_color #0000007F
    '';
  };
}
