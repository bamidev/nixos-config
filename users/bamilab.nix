{ lib, pkgs, ... }:
{
  imports = [
    ./desktop.nix
  ];

  home.stateVersion = "24.11";

  home.activation.updateExtraConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -e /etc/xdg/extra-config ]; then
      export GIT_SSH="${pkgs.openssh}/bin/ssh"
      ${lib.getExe pkgs.git} -C /etc/xdg/extra-config pull || true
    fi
  '';

  programs = {
    git.settings = {
      user = {
        name = "Bamidev";
        email = "bamidev@pm.me";
      };
    };
  };
}
