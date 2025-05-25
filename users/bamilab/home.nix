{ pkgs, lib, ... }:
let defaults = import ../defaults.nix { pkgs = pkgs; lib = lib; }; in
defaults // {
	programs = {
      git = {
        enable = true;

		userName = "Bamidev";
		userEmail = "bamidev@pm.me";
	  };
	};
}
