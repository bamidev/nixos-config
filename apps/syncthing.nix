{
  services.syncthing = { 
    enable = true;

    group = "users";
    user = "bamilab";

    dataDir = "/home/bamilab/";
    configDir = "/home/bamilab/Documents/.config/syncthing";
    overrideFolders = true;
    settings = {
      options = {
        urAccepted = -1;
	  };

      folders = {
        ".password-store" = {
          path = "/home/bamilab/.password-store";
          ignorePerms = false;
        };
        "Documents" = {
          path = "/home/bamilab/Documents";
		  ignorePerms = true;
        };
        "Pictures" = {
          path = "/home/bamilab/Pictures";
		  ignorePerms = true;
        };
      };
    };
  };
}
