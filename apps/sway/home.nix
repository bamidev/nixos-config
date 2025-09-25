{ pkgs, lib, ... }:
let
  i3status-wrapper = pkgs.writers.writeBashBin "i3status-wrapper" ''
    ${pkgs.i3status}/bin/i3status -c /etc/i3status.conf | while :
    do
      read -r LINE
      if [ "''${LINE:0:3}" == ",[{" ]; then
        TODO_COUNT=$(cat $HOME/Documents/todo.txt | wc -l)
        echo ",[{\"name\":\"todo\",\"full_text\":\"TODOs: $TODO_COUNT\"},''${LINE:2}"
      else
        echo "$LINE"
      fi
     done
  '';
  monitors = import ../../desktop/monitors.nix;
  startupCommands = import ../../desktop/startup.nix {pkgs=pkgs; lib=lib;};
  theme = import ../../theme.nix;
in {
  wayland.windowManager.sway = {
    # Sway is only enabled in home-manager in order to generate the config files.
    enable = true;
    package = null;

    config = rec {
      menu = "wofi --show run";
      modifier = "Mod4";

      colors = with theme; rec {
        background = "#${theme.background}";
        focused = {
          background = "#${bg.blue}";
          border = "#${dark.blue}";
          childBorder = "#${dark.blue}";
          indicator = "#2e9ef4";
          text = "#${foreground}";
        };
        focusedInactive = focused;
        placeholder = unfocused;
        unfocused = {
          background = "#${dim.blue}";
          border = "#${dim.blue}";
          childBorder = "#${dim.blue}";
          indicator = "#292d2e";
          text = "#${foreground}";
        };
        urgent = {
          background = "#${bg.red}";
          border = "#${normal.red}";
          childBorder = "#${normal.red}";
          indicator = "#900000";
          text = "#${foreground}";
        };
      };

      output = builtins.listToAttrs (lib.lists.forEach monitors.all (x:
        {
          name = x.id;
          value = {
            #bg = "~/Pictures/wallpapers/default.jpg fill";
            position = toString x.position.x + "," + toString x.position.y;
          };
        }
      ));

      /*output = {
        eDP-1 = {
          bg = "~/Pictures/laptop-wallpaper.png fill";
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
      };*/
      keybindings = lib.mkOptionDefault{
        "${modifier}+w" = "exec librewolf";
        "${modifier}+t" = "exec ${pkgs.alacritty}/bin/alacritty --class floating-terminal";
        "XF86MonBrightnessDown" = "exec sudo-brightness-down";
        "XF86MonBrightnessUp" = "exec sudo-brightness-up";
        "XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%''";
        "XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'";
        "XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";
      };
      terminal = "bash -c \"$(printenv TERMINAL)\"";
      startup = lib.lists.forEach startupCommands (x: { command = x; }) ++ [
        # Lock screen when idle
        {
          command = ''
            swayidle -w \
            timeout 300 'swaylock -f -c ${theme.background}' \
            timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
            before-sleep 'swaylock -f -c ${theme.background}'
          '';
        }
      ];

      bars = [
        {
          # https://mynixos.com/home-manager/options/wayland.windowManager.sway.config.bars.*.colors
          colors = with theme; {
            activeWorkspace = {
              background = "#${bg.blue}";
              border = "#${normal.blue}";
              text = "#${foreground}";
            };
            background = "#${background}cf";
            inactiveWorkspace = {
              background = "#${dim.blue}";
              border = "#${dim.blue}";
              text = "#${foreground}";
            };
            statusline = "#${foreground}";
            separator = "#${bg.white}";
            urgentWorkspace = {
              background = "#${bg.red}";
              border = "#${normal.red}";
              text = "#${foreground}";
            };
          };
          command = "${pkgs.sway}/bin/swaybar";
          statusCommand = "${i3status-wrapper}/bin/i3status-wrapper";
          position = "top";
          trayOutput = "*";
          workspaceButtons = true;
          workspaceNumbers = true;
        }
      ];

      workspaceLayout = "tabbed";
    };

    extraConfig = ''
      # Window settings
      for_window [app_id="Alacritty"] opacity 0.8, resize set width 880 px
      for_window [app_id="floating-terminal"] floating enable, sticky enable, opacity 0.85, resize set width 800 height 1000, move right 500
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
      blur_noise 0.15
      blur_brightness 1
      blur_contrast 0.7
      blur_saturation 1.2
      corner_radius 5
      shadows enable
      shadows_on_csd enable
      shadow_blur_radius 25
      shadow_color #0000007F
      shadow_offset 0 5
      shadow_inactive_color #0000007F
    '';
  };
}
