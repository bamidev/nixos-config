{ lib, pkgs, ... }:

let
  brightness-down = pkgs.writers.writeBashBin "brightness-down" ''
    MIN=10
    B=$(echo $(cat '/sys/class/backlight/intel_backlight/brightness') - 100 | bc)
    echo $(( B > MIN ? B : MIN )) | tee /sys/class/backlight/intel_backlight/brightness
    '';
  brightness-up = pkgs.writers.writeBashBin "brightness-up" ''
    B=$(echo $(cat '/sys/class/backlight/intel_backlight/brightness') + 100 | bc)
    M=$(cat /sys/class/backlight/intel_backlight/max_brightness)
    echo $(( B > M ? M : B )) | tee /sys/class/backlight/intel_backlight/brightness
    '';
  current-workspace = pkgs.writers.writeBashBin "current-workspace" ''
    if [ ! -z "$SWAYSOCK" ]; then
      ${pkgs.sway}/bin/swaymsg -t get_workspaces -r | ${pkgs.jq}/bin/jq -r -c '.[] | select(.focused == true) | .name'
    elif [ ! -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
      ${pkgs.hyprland}/bin/hyprctl -j activeworkspace | ${pkgs.jq}/bin/jq -r .name
    else
      echo Unknown deskop environment.
      exit 1
    fi
  '';
  here = pkgs.writers.writeBashBin "here" ''
    set -e
    CURRENT_WORKSPACE=$(${current-workspace}/bin/current-workspace)
    if [ -z "$CURRENT_WORKSPACE" ]; then
      exit 1
    fi

    mkdir -p ~/.here
    echo $PWD > ~/.here/$CURRENT_WORKSPACE
    echo Remembered the working dir \"$PWD\" for workspace $CURRENT_WORKSPACE.
  '';
  pick-random-wallpaper = pkgs.writers.writeBashBin "pick-random-wallpaper" ''
    set -e
    function pick_random_file() {
      PICKED=$(find "$1" -mindepth 1 -maxdepth 1 | shuf --random-source=/dev/random | head -n 1)
      if [ -d "$PICKED" ]; then
        pick_random_file "$PICKED"
      else
        echo $PICKED
      fi
    }

    WALLPAPER=$(pick_random_file /var/lib/syncthing/Sync/wallpapers)
    ${lib.getExe pkgs.swaybg} -m fill -i "$WALLPAPER"
  '';
  sudo-brightness-down = pkgs.writers.writeBashBin "sudo-brightness-down" ''
    sudo ${brightness-down}/bin/brightness-down
  '';
  sudo-brightness-up = pkgs.writers.writeBashBin "sudo-brightness-up" ''
    sudo ${brightness-up}/bin/brightness-up
  '';
in {
  imports = [
    ./scripts/bamilab.nix
    ./scripts/therp.nix
  ];

  environment.systemPackages = [
    brightness-up
    brightness-down
    current-workspace
    here
    pick-random-wallpaper
    sudo-brightness-up
    sudo-brightness-down
  ];

  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
        {
          command = "${brightness-up}/bin/brightness-up";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${brightness-down}/bin/brightness-down";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl restart openvpn-protonvpn";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = ["wheel"];
    }];
  };
}
