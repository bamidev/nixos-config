{ pkgs, lib, ... }:
{
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
