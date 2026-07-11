{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kubectl
  ];

  virtualisation.containerd.enable = true;
}
