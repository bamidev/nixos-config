{
  home.stateVersion = "24.11";

  imports = [
    ../apps/sway.nix
  ];

  programs = {
    home-manager.enable = true;

    alacritty = import ../apps/alacritty.nix;

    bash = {
      enable = true;
        profileExtra = ''
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
            gsettings set org.gnome.desktop.interface text-scaling-factor 1.1
            sway
        '';
      };

	element-desktop = {
      enable = true;

	  settings = {
        default_theme = "dark";
	  };
	};

	# For some reason, neovim will not be invoked with the -u flag for the customRC code as non-root users,
    # which should load our init.lua file.
    # This is a workaround which will still load the init.lua file even for non-root users.
    neovim.enable = true;
    neovim.extraConfig = ''
luafile /etc/nixos/apps/neovim/init.lua
'';
  };
}
