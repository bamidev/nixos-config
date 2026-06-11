{ lib, pkgs, ... }:
{
  imports = [
    ./desktop.nix
  ];

  home.stateVersion = "24.11";


  home.activation.updateExtraConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export GIT_SSH="${pkgs.openssh}/bin/ssh"
    if [ ! -e /etc/xdg/extra-config ]; then
      ${lib.getExe pkgs.git} clone https://github.com/bamidev/extra-config /etc/xdg/extra-config
    else
      ${lib.getExe pkgs.git} -C /etc/xdg/extra-config pull
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
