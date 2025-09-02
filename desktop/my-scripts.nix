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
  install-protonvpn = pkgs.writers.writeBashBin "install-protonvpn" ''
    set -e
    sudo mkdir -p /root/openvpn
    pass protonvpn/openvpn-config | sudo tee /root/openvpn/protonvpn.conf > /dev/null
    pass protonvpn/openvpn-auth | sudo tee /root/openvpn/protonvpn.auth > /dev/null
  '';
  install-ssh-keys = pkgs.writers.writeBashBin "install-ssh-keys" ''
    set -e
    mkdir -p /home/bamilab/.ssh
    pass ssh/bamilab/public > /home/bamilab/.ssh/id_ed25519.pub
    pass ssh/bamilab/private > /home/bamilab/.ssh/id_ed25519
    chmod 600 /home/bamilab/.ssh/id_ed25519
    ssh-add || true
    sudo -u therp mkdir -p /home/therp/.ssh
    pass ssh/therp/public | sudo -u therp tee /home/therp/.ssh/id_rsa.pub > /dev/null
    pass ssh/therp/private | sudo -u therp tee /home/therp/.ssh/id_rsa > /dev/null
    sudo chmod 600 /home/therp/.ssh/id_rsa
    # TODO: Add the therp ssh key to the ssh-agent
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
  transfer-pgp-keys = pkgs.writers.writeBashBin "transfer-pgp-keys" ''
    ${pkgs.gnupg}/bin/gpg --export-secret-keys --armor > /tmp/gpg-secret-keys.pem
    ${pkgs.openssh}/bin/scp /tmp/gpg-secret-keys.pem bamilab@$1:/tmp/gpg-secret-keys.pem
    ${pkgs.openssh}/bin/ssh bamilab@$1 gpg --import /tmp/gpg-secret-keys.pem
  '';
in {
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
      ];
      groups = ["wheel"];
    }];
  };

  users.users.bamilab.packages = [ install-protonvpn install-ssh-keys ];
}
