{ config, pkgs, ... }:
let
  secretsPath = config.services.kubernetes.secretsPath;
in
{
  environment = {
    systemPackages = with pkgs; [
      kubectl
    ];
  };

  services.kubernetes = {
    caFile = "${secretsPath}/ca.pem";

    masterAddress = "192.168.0.254";
    clusterCidr = "172.0.0.0/16";

    # Trying to fix flannel configuration:
    kubeconfig = {
      server = "https://192.168.0.254:6443";

      caFile = "${secretsPath}/ca.pem";
      certFile = "${secretsPath}/admin.pem";
      keyFile = "${secretsPath}/admin-key.pem";
    };
  };

  system.activationScripts = {
    installKubernetesCerts = {
      deps = [ ];
      text = ''
        function install() {
          if [ -e /home/bamilab/.certs/$1.pem ]; then
            mv -f /home/bamilab/.certs/$1.pem ${secretsPath}/$1.pem
          fi
        }

        install ca
        install admin
        install admin-key
        install apiserver
        install apiserver-key
        install apiserver-account-privkey
        install apiserver-account-pubkey
        install apiserver-account-signing-privkey
        install apiserver-account-signing-pubkey
        install controller-manager
        install controller-manager-key
        install etcd
        install etcd-key
        install kubelet
        install kubelet-key
        install proxy
        install proxy-key
        install scheduler
        install scheduler-key

        chown kubernetes:kubernetes ${secretsPath}/*.pem
        chown bamilab:kubernetes ${secretsPath}/admin.pem
        chown bamilab:kubernetes ${secretsPath}/admin-key.pem
        chmod 660 ${secretsPath}/admin-key.pem
        chown etcd:kubernetes ${secretsPath}/etcd.pem
        chown etcd:kubernetes ${secretsPath}/etcd-key.pem
        chmod 660 ${secretsPath}/etcd-key.pem
      '';
    };

    createContainerdSnapshotterPool = {
      deps = [ ];
      text = ''
        SNAPSHOTTER_PATH="/var/lib/containerd/io.containerd.snapshotter.v1.zfs"
        if [ ! -e "$SNAPSHOTTER_PATH" ]; then
          ${pkgs.zfs}/bin/zfs create -o mountpoint=$SNAPSHOTTER_PATH hdd/containerd
        fi
      '';
    };
  };
}
