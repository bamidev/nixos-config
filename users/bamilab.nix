{ ... }:
{
  imports = [
    ./desktop.nix
  ];

  home.stateVersion = "24.11";

  programs = {
    git.settings = {
      user.name = "Bamidev";
      user.email = "bamidev@pm.me";
    };
  };
}
