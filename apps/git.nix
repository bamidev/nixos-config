{ ... }: {
  environment = {
    etc = {
      gitconfig.text = ''
        [alias]
        a = "add"
        b = "branch"
        c = "checkout"
        cm = "commit"
        d = "diff"
        l = "log"
        p = "pull"
        s = "status"

        [core]
        editor = "nvim"

        [push]
        autoSetupRemote = true
      '';

      "gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=Adwaita:dark
        gtk-application-prefer-dark-theme=1
      '';
    };

    shellAliases = {
      g = "git";
      gb = "git branch";
      gd = "git diff";
      gs = "git status";
    };
  };
}
