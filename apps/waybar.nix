{ ... }:
let
  theme = import ../theme.nix;
in
{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 15;
        modules-left = [
          "hyprland/workspaces"
          "custom/todo"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "custom/vpn"
          "pulseaudio"
          "cpu"
          "memory"
          "battery"
          "tray"
        ];

        cpu = {
          "interval" = 10;
          "format" = "CPU: {usage}%";
        };
        memory = {
          "interval" = 30;
          "format" = "RAM: {used:0.1f}GiB ({percentage}%) Swap: {swapPercentage}%";
        };
        battery = {
          "bat" = "BAT0";
          "states" = {
            "good" = 95;
            "warning" = 30;
            "critical" = 5;
          };
          "format" = "Power: {capacity}%";
          "format-charging" = "Power: {capacity}% (charging)";
          "format-plugged" = "Power: {capacity}% (plugged)";
        };
        clock = {
          "format" = "{:%Y/%m/%d %H:%M}";
          "tooltip-format" = "<tt><small>{calendar}</small></tt>";
          "calendar" = {
            "format" = {
              "months" = "<span color='#ffead3'><b>{}</b></span>";
              "today" = "<span color='#ff6699'><b>{}</b></span>";
            };
          };
        };
        pulseaudio = {
          "format" = "{icon} {volume}%";
          "format-icons" = {
            "default" = [ "Speaker" ];
          };
          "on-click" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "on-click-right" = "pavucontrol";
          "format-muted" = "Muted {volume}%";
        };

        "custom/vpn" = {
          interval = 1;
          format = "VPN: {}";
          exec = "ip add show | grep -qF tun0 && echo ✅ || echo ☒";
          max-length = 100;
          on-click = "sudo-restart-vpn";
          on-click-right = "sudo-stop-vpn";
        };

        "custom/todo" = {
          interval = 10;
          format = "TODOs: #{}";
          exec = "cat $HOME/Documents/todo.txt | wc -l";
        };
      };
    };

    style = with theme; ''
      #waybar { 
        background-color: #${background}; 
        color: #${foreground}; 
      }

      label {
        color: #${foreground};
      }

      .module {
        padding-left: 5px;
        padding-right: 5px;
      }

      #clock,
      #tray,
      #memory,
      #pulseaudio {
        background-color: #${dim.black};
        color: #${foreground};
      }

      #battery,
      #cpu {
        background-color: #${background};
        color: #${foreground};
      }

      #taskbar button.active {
        background-color: #${bg.blue};
      }

      #workspaces {
        color: #${foreground};
      }

      #workspaces button.active {
        background-color: #${bg.blue};
      }
    '';
  };
}
