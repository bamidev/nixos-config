{ pkgs, ... }:
let
  setup = pkgs.writers.writeBashBin "setup" ''
    SSH_CONFIG_DIR="/home/therp/.ssh/config.d"
    if [ ! -d "$SSH_CONFIG_DIR" ]; then
      git clone git@gitlab.therp.nl:therp/ssh-config.git "$SSH_CONFIG_DIR"
    fi


    PASSWORD_STORE_DIR="/home/therp/.password-store"
    if [ ! -d "$PASSWORD_STORE_DIR" ]; then
      mkdir ~/.password-store
      pass git init
      pass git remote add origin git@gitlab.therp.nl:therp/password-store.git
      pass git fetch
      pass git branch --set-upstream-to=origin/master master
      pass git pull --rebase
    fi
  '';
in
{
  users.users.therp.packages = [ setup ];
}
