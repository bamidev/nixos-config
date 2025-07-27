{ pkgs, ... }: {
  #environment.systemPackages = with pkgs; [];

  imports = [
    ./server.nix

    ./radicale.nix
  ];
}
