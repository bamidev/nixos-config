{ lib, pkgs, ... }:
let
  theme = import ../theme.nix;
in {
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 20;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "cpu" "memory" "battery" "tray" ];

        cpu = { 
          "interval" = 10;
          "format" = "CPU: {usage}%";
        };
        memory = {
          "interval" = 30;
          "format" = "RAM: {used:0.1f}GiB/{total:0.1f}GiB ({percentage}%) SWAP: {swapUsed:0.1f}GiB/{swapTotal:0.1f}GiB ({swapPercentage}%)";
        };
        battery = {
          "bat" = "BAT0";
          "states" = {
            "good" = 95;
            "warning" = 30;
            "critical" = 5;
          };
          "format" = "BAT0: {capacity}%";
          "format-charging" = "BAT0: {capacity}% (charging)";
          "format-plugged" = "BAT0: {capacity}% (plugged)";
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
            "default" = ["\uf026" "\uf027" "\uf028"];
          };
          "on-click" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "on-click-right" = "pavucontrol";
          "format-muted" = "\uf00d {volume}%";
        };
      };
    };

    style = with theme; ''
      #waybar { 
        background-color: #${background}; 
        color: #${foreground}; 
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
    '';
  };
}
