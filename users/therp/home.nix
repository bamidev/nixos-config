{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    black
    gcc14
    gnumake
    postgres-lsp

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
    #element-desktop = {
    #  settings = {
    #    default_server_config = {
    #      "m.identity" = {
    #        base_url = "https://welcome.therp.nl";
    #        server_name = "welcome.therp.nl";
    #      };
    #	};
    #  };
    #};

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
