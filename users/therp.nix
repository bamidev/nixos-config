{ pkgs, username, ... }:
{
  home.packages = with pkgs; [
    black
    gnumake

    # Required to build Python
    bzip2
    cyrus_sasl
    libffi
    ncurses
    openldap
    openssl
    readline
    zlib
  ];

  programs = {
    firefox.policies.Cookies.Allow = ["https://therp.nl"];

    git = {
      userName = "Danny de Jong";
      userEmail = "ddejong@therp.nl";
    };

    ssh = {
      enable = true;

      extraConfig = "Include ~/.ssh/config.d/*.conf";
    };
  };

  services.syncthing = 
    let
      homeDir = "/home/${username}";
    in {
      settings.folders =
        let
          defaults = import ../apps/syncthing/defaults.nix; 
        in {
          "Documents" = defaults.defaultFolder // {
            path = "${homeDir}/Documents";
          };
        };
  };
}
