{ pkgs, ... }: {
  #environment.systemPackages = with pkgs; [];

  imports = [
    ./server.nix

    ./baikal.nix
  ];
}
