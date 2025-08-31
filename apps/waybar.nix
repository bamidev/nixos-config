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
        height = 15;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "custom/vpn" "pulseaudio" "cpu" "memory" "battery" "tray" ];

        cpu = { 
          "interval" = 10;
          "format" = "CPU: {usage}%";
        };
        memory = {
          "interval" = 30;
          "format" = "RAM: {used:0.1f}GiB/{total:0.1f}GiB ({percentage}%)";
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

        "custom/vpn" ={
          interval = 3;
          format = "VPN: {}";
          exec = "ip add show | grep -qF tun0 && echo Connected || echo Disconnected";
          max-length = 100;
          on-click = "systemctl restart openvpn-protonvpn";
        };
      };
    };

    style = with theme; ''
      #waybar { 
        background-color: #${background}; 
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
