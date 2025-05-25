{ pkgs, lib, ... }:
let defaults = import ../defaults.nix { pkgs = pkgs; lib = lib; }; in
defaults // {
  programs = {
    git = {
      enable = true;
        userName = "Danny de Jong";
	userEmail = "ddejong@therp.nl";
    };

    ssh = {
      enable = true;

      extraConfig = "Include ~/.ssh/config.d/*.conf";
    };
  };
}
