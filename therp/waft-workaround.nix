{ pkgs, ... }:

{
  system.activationScripts.text = ''
ln -sf ${pkgs.coreutils-full}/bin/* /bin
ln -sf ${pkgs.coreutils-full}/bin/cut /usr/bin/cut
ln -sf ${pkgs.coreutils-full}/bin/dirname /usr/bin/dirname
ln -sf ${pkgs.gnused}/bin/sed /usr/bin/sed;
ln -sf ${pkgs.git}/bin/git /usr/bin/git
ln -sf ${pkgs.wget}/bin/wget /usr/bin/wget
'';
}
