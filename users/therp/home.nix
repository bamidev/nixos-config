{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    postgres-lsp
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
