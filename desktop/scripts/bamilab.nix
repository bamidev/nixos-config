{ lib, pkgs, ... }:

let
  install-protonvpn = pkgs.writers.writeBashBin "install-protonvpn" ''
    set -e
    sudo mkdir -p /root/openvpn
    pass protonvpn/openvpn-config | sudo tee /root/openvpn/protonvpn.conf > /dev/null
    pass protonvpn/openvpn-auth | sudo tee /root/openvpn/protonvpn.auth > /dev/null
  '';
  install-ssh-keys = pkgs.writers.writeBashBin "install-ssh-keys" ''
    set -e
    mkdir -p /home/bamilab/.ssh
    pass ssh/bamilab/public > /home/bamilab/.ssh/id_ed25519.pub
    pass ssh/bamilab/private > /home/bamilab/.ssh/id_ed25519
    chmod 600 /home/bamilab/.ssh/id_ed25519
    ssh-add || true
    sudo -u therp mkdir -p /home/therp/.ssh
    pass ssh/therp/public | sudo -u therp tee /home/therp/.ssh/id_rsa.pub > /dev/null
    pass ssh/therp/private | sudo -u therp tee /home/therp/.ssh/id_rsa > /dev/null
    sudo chmod 600 /home/therp/.ssh/id_rsa
    # TODO: Add the therp ssh key to the ssh-agent
  '';
  transfer-pgp-keys = pkgs.writers.writeBashBin "transfer-pgp-keys" ''
    ${pkgs.gnupg}/bin/gpg --export-secret-keys --armor > /tmp/gpg-secret-keys.pem
    ${pkgs.openssh}/bin/scp /tmp/gpg-secret-keys.pem bamilab@$1:/tmp/gpg-secret-keys.pem
    ${pkgs.openssh}/bin/ssh bamilab@$1 gpg --import /tmp/gpg-secret-keys.pem
  '';
in {
  users.users.bamilab.packages = [ install-protonvpn install-ssh-keys transfer-pgp-keys ];
}
