{ nixosConfig, ... }:
let
  defaultQuodLibetConfig = ''
    [library]
    watch = true

    [player]
    replaygain_mode = auto

    [settings]
    columns = ~#track,~people,~title~version,~album~discsubtitle,~#samplerate,~#bitdepth,~#length,replaygain_track_gain
    default_rating = 0.5
    scan = /home/bamilab/Music:/run/user/1000/gvfs/dav\:host=nextcloud.bamilab.space,ssl=false,prefix=%2Fremote.php%2Fdav%2Ffiles%2Fbamilab/Music
  '';
in
{
  imports = [
    ./default.nix
  ];

  home = {
    stateVersion = "24.11";

    file = {
      ".config/gtk-3.0/bookmarks".text = ''
        dav://nextcloud.local.bamilab.space/remote.php/dav/files/bamilab/
        dav://nextcloud.bamilab.space/remote.php/dav/files/bamilab/Music
      '';

      ".config/quodlibet/default-config".text = defaultQuodLibetConfig;

      ".kube/config".text = import ./bamilab/kubeconfig.nix { host = "private.bamilab.space"; };
      ".kube/config-local".text = import ./bamilab/kubeconfig.nix {
        host = nixosConfig.homelab.kubesServerIp;
      };
    };

    shellAliases = {
      k = "sudo -E kubectl";
      kl = "sudo -E kubectl --kubeconfig=~/.kube/config-local";
    };
  };

  programs.git.settings = {
    user = {
      name = "Bamidev";
      email = "bamidev@pm.me";
    };
  };
}
