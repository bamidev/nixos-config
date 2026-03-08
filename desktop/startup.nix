{ pkgs, lib, ... }: [
  # Some desktop utilities
  "${lib.getExe pkgs.wlsunset} -l 51.0 -L 5.4 -t 3500"
  "pick-random-wallpaper"
  "${lib.getExe pkgs.protonmail-bridge} -n"

  # GUI applications
  "${lib.getExe pkgs.thunderbird}"
  "${lib.getExe pkgs.element-desktop} --hidden"
  "${lib.getExe pkgs.session-desktop}"
  "${lib.getExe pkgs.signal-desktop} --use-tray-icon"
]
