{ pkgs, ... }: {
  #environment.systemPackages = with pkgs; [];

  imports = [
    ./server.nix

    ./nextcloud.nix
    ./radicale.nix
  ];
}
