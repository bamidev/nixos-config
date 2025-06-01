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
  sudo-brightness-down = pkgs.writeShellScriptBin "sudo-brightness-down" ''
#!/bin/bash
sudo ${brightness-down}/bin/brightness-down
'';
  sudo-brightness-up = pkgs.writeShellScriptBin "sudo-brightness-up" ''
#!/bin/bash
sudo ${brightness-up}/bin/brightness-up
'';
in {
  environment.systemPackages = [ brightness-up brightness-down sudo-brightness-up sudo-brightness-down ];

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
}
