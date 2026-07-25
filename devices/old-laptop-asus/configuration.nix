# This laptop has a decent amount of disk space & processing power, but is very fragile:
# * If you move it around there is a high change you get a kernel panic.
# * If you enable the firmware of the WiFi chip, you will get many errors, which might also be
#   another cause of the kernel panics.
# * If any pressure is added to the ethernet cable, the ethernet connectivity ceases to work.
# It is a decent worker node, as long as it is left untouched.
{ ... }:
{
  imports = [
    ../wifi.nix
    ../../lab/kubernetes/control-node.nix
    ../../lab/kubernetes/worker-node.nix
  ];

  config = {
    homelab = {
      controlNodeId = 3;
      mainNetworkInterface = "enp4s0";
    };
  };
}
