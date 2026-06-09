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
    };

    shellAliases = {
      g = "git";
      ga = "git add";
      gb = "git branch";
      gc = "git checkout";
      gcm = "git commit";
      gd = "git diff";
      gp = "git pull";
      gs = "git status";
    };
  };
}
