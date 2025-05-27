{
  home.stateVersion = "24.11";

  imports = [
    ../sway.nix
  ];

  home.sessionVariables = rec {
    BROWSER = "librewolf";
    EDITOR = "nvim";
    TERMINAL = "konsole";
    VISUAL = EDITOR;
  };


  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
	  profileExtra = ''
sway
'';
	};

	# For some reason, neovim will not be invoked with the -u flag for the customRC code as non-root users,
    # which should load our init.lua file.
    # This is a workaround which will still load the init.lua file even for non-root users.
    neovim.enable = true;
    neovim.extraConfig = ''
luafile /etc/nixos/neovim/init.lua
'';
  };
}
