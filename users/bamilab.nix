{ ... }:
{
  imports = [
    ./desktop.nix
  ];

  home.stateVersion = "24.11";

  programs = {
    git = {
      userName = "Bamidev";
      userEmail = "bamidev@pm.me";
    };
  };
}
