{ lib, ... }:
{
  # Put a default config file in place before the first startup of quodlibet, so that it takes up some default settings, like what folders to watch
  home.activation.quodlibetDefaultConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    DEFAULT_CONFIG_FILE="$HOME/.config/quodlibet/default-config"
    CONFIG_FILE="$HOME/.config/quodlibet/config"

    if [ -e "$DEFAULT_CONFIG_FILE" ] && [ ! -e "$CONFIG_FILE" ]; then
      mkdir -p "$(dirname "$CONFIG_FILE")"
      cp "$DEFAULT_CONFIG_FILE" $CONFIG_FILE
    fi
  '';
}
