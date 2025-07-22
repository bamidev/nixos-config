{ pkgs, ... }:

let
  brightness-down = pkgs.writeShellScriptBin "brightness-down" ''
    #!/bin/bash
    MIN=10
    B=$(echo $(cat '/sys/class/backlight/intel_backlight/brightness') - 100 | bc)
    echo $(( B > MIN ? B : MIN )) | tee /sys/class/backlight/intel_backlight/brightness
    '';
  brightness-up = pkgs.writeShellScriptBin "brightness-up" ''
    #!/bin/bash
    B=$(echo $(cat '/sys/class/backlight/intel_backlight/brightness') + 100 | bc)
    M=$(cat /sys/class/backlight/intel_backlight/max_brightness)
    echo $(( B > M ? M : B )) | tee /sys/class/backlight/intel_backlight/brightness
    '';
  current-workspace = pkgs.writers.writeBashBin "current-workspace" ''
    ${pkgs.sway}/bin/swaymsg -t get_workspaces -r | ${pkgs.jq}/bin/jq -r -c '.[] | select(.focused == true) | .name'
  '';
  here = pkgs.writers.writeBashBin "here" ''
    set -e
    CURRENT_WORKSPACE=$(${current-workspace}/bin/current-workspace)
    mkdir -p ~/.here
    echo $PWD > ~/.here/$CURRENT_WORKSPACE
    echo Remembered the working dir \"$PWD\" for workspace $CURRENT_WORKSPACE.
  '';
  install-ssh-keys = pkgs.writers.writeBashBin "install-ssh-keys" ''
    set -e
    pass ssh/bamilab/public > /home/bamilab/.ssh/id_25519.pub
    pass ssh/bamilab/private > /home/bamilab/.ssh/id_25519
    chmod 600 /home/bamilab/.ssh/id_25519
    ssh-add || true
    pass ssh/therp/public | sudo -u therp tee /home/therp/.ssh/id_rsa.pub > /dev/null
    pass ssh/therp/private | sudo -u therp tee /home/therp/.ssh/id_rsa > /dev/null
    sudo chmod 600 /home/therp/.ssh/id_rsa
    # TODO: Add the therp ssh key to the ssh-agent
  '';
  sudo-brightness-down = pkgs.writeShellScriptBin "sudo-brightness-down" ''
    #!/bin/bash
    sudo ${brightness-down}/bin/brightness-down
  '';
  sudo-brightness-up = pkgs.writeShellScriptBin "sudo-brightness-up" ''
    #!/bin/bash
    sudo ${brightness-up}/bin/brightness-up
  '';
in {
  environment.systemPackages = [
    brightness-up
    brightness-down
    current-workspace
    here
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
    extraConfig = with pkgs; ''
      Defaults:picloud secure_path="${lib.makeBinPath [
        brightness-up
        brightness-down
        sudo-brightness-up
        sudo-brightness-down
      ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
  };

  users.users.bamilab.packages = [ install-ssh-keys ];
}
