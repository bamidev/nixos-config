{ pkgs, ... }:
let
  theme = import ../../theme.nix;
in {
  environment.etc."i3status.conf".text = with theme; ''
    general {
      output_format = "i3bar"
      colors = true
      color_good = "#${bright.green}"
      color_bad = "#${bright.red}"
      color_degraded = "#${dim.white}"
      interval = 1
    }

    order += "ipv6"
    order += "disk /"
    order += "run_watch DHCP"
    order += "run_watch VPNC"
    order += "path_exists VPN"
    order += "wireless _first_"
    order += "ethernet eth0"
    order += "battery 0"
    order += "cpu_temperature 0"
    order += "memory"
    order += "tztime local"

    wireless _first_ {
      format_up = "WiFi: (%quality at %essid, %bitrate) %ip"
      format_down = "WiFi: down"
    }

    ethernet eth0 {
      format_up = "Ethernet: %ip (%speed)"
      format_down = "Ethernet: down"
    }

    battery 0 {
      format = "%status %percentage %remaining"
      format_down = "No battery"
      status_chr = "Battery Charging"
      status_bat = "Battery"
      status_unk = "? UNK"
      status_full = "Battery Full"
      status_idle = "Battery Idle"
      path = "/sys/class/power_supply/BAT%d/uevent"
      low_threshold = 10
    }

    run_watch DHCP {
      pidfile = "/var/run/dhclient*.pid"
    }

    path_exists VPN {
      path = "/proc/sys/net/ipv4/conf/tun0"
    }

    tztime local {
      format = "%Y-%m-%d %H:%M:%S"
      timezone = "Europe/Amsterdam"
    }

    cpu_temperature 0 {
      format = "CPU: %degrees °C"
      path = "/sys/devices/platform/coretemp.0/hwmon/hwmon6/temp1_input"
    }

    memory {
      format = "Memory: %used"
      threshold_degraded = "10%"
      format_degraded = "Memory Free: %free"
    }

    disk "/" {
      format = "Diskspace: %free"
    }
  '';

  programs.sway = {
    enable = true;

    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      # SDL:
      export SDL_VIDEODRIVER=wayland
      # QT (needs qt5.qtwayland in systemPackages):
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };
}
