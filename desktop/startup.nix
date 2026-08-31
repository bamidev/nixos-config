{ pkgs, lib, ... }: [
  "${lib.getExe pkgs.poweralertd}"

  # Some desktop utilities
  "${lib.getExe pkgs.wlsunset} -l 51.0 -L 5.4 -t 3500"
  "pick-random-wallpaper"
  "${lib.getExe pkgs.protonmail-bridge} -n"

  # GUI applications
  "thunderbird" # Email
  "element-desktop --hidden" # Private federated messaging
  "session-desktop" # Private P2P messaging
  "signal-desktop --use-tray-icon" # Private messaging
  "vikunja-desktop" # Todo lists
]
