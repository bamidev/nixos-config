{ pkgs, ... }:
{
  imports = [
    ./desktop.nix
  ];

  home = {
    stateVersion = "24.11";

    packages = with pkgs; [
      black
      pre-commit
    ];
  };

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
}
