{ pkgs, lib, ... }:
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
