{ pkgs, lib, ... }:
{
  home.file.".init.sh".text = ''
    #!${pkgs.bash}/bin/bash
    if [ ! -d "~/.ssh/config.d" ]; then
      (cd ~/.ssh; git clone git@gitlab.therp.nl:therp/ssh-config.git config.d)
    else
      (cd ~/.ssh/config.d; git pull)
    fi
  '';

  home.packages = with pkgs; [
    black
    gcc14
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
