# When this module is included in the device configuration, you will have an assortment of scripts
# available at your command to generate - and deploy all the certificates needed for a kubernetes
# node.
{ config, pkgs, ... }:
let
  secretsPath = "${config.services.kubernetes.secretsPath}";

  # The configuration files that are used to generate certificates
  caConfig = pkgs.writers.writeText "ca-config.json" ''
    {
      "signing": {
        "default": {
          "expiry": "87600h"
        },
        "profiles": {
          "kubernetes": {
            "usages": ["signing", "key encipherment", "server auth", "client auth"],
            "expiry": "87600h"
          }
        }
      }
    }
  '';
  caCsr = pkgs.writers.writeText "ca-csr.json" ''
    {
      "CN": "Kubernetes Root CA",
      "key": {
        "algo": "ecdsa",
        "size": 384
      },
      "names": [{
        "O": "Kubernetes"
      }]
    }
  '';
  certCsr =
    commonName: org:
    pkgs.writers.writeText "component-csr.json" ''
      {
        "CN": "${commonName}",
        "key": {
          "algo": "ecdsa",
          "size": 384
        },
        "names": [{
          "O": "${org}"
        }]
      }
    '';
  componentCsr = name: certCsr "system:kube-${name}" "Kubernetes";

  # All the CA scripts:
  # This script generates a new Kubernetes root CA certificate, and stores it into the pass store.
  kubesGenCaCert = pkgs.writers.writeBashBin "kubes-gen-ca-cert" (
    with pkgs;
    ''
      set -ex
      ${cfssl}/bin/cfssl gencert -initca ${caCsr} | ${cfssl}/bin/cfssljson -bare ca
      cat ./ca.pem | pass insert -m homelab/ca/ca-cert
      cat ./ca-key.pem | pass insert -m homelab/ca/ca-key
      sudo mv ca.pem ${secretsPath}/ca.pem
      rm ca.csr
      ${busybox}/bin/shred -u ca-key.pem
    ''
  );

  # Call this from any script that needs to access the root certificate
  kubesLoadCaCert = pkgs.writers.writeBashBin "kubes-load-ca-cert" ''
    set -e
    pass homelab/ca/ca-cert > ${secretsPath}/ca.pem
    pass homelab/ca/ca-key > /tmp/ca-key.pem
    chmod 1600 /tmp/ca-key.pem
  '';

  # Call this when you have called `kubes-load-ca-cert`, at the end of your script
  kubesUnloadCaCert = pkgs.writers.writeBashBin "kubes-unload-ca-cert" (
    with pkgs;
    ''
      set -e
      if [ -f /tmp/ca-key.pem ]; then
        ${busybox}/bin/shred -u /tmp/ca-key.pem
      fi
    ''
  );

  # This script generates a new control node certificate, which needs to include the virtual IP as well.
  kubesGenCert = pkgs.writers.writeBashBin "kubes-gen-cert" (
    with pkgs;
    ''
      set -ex
      HOSTNAME=$1
      ADDRESSES=$2
      CERTNAME=$3
      CSR_FILE=$4

      # The following IP addresses are added as a valid hostname:
      # * 10.0.0.1 - This is needed because because the API server is often reached at this IP from several components.
      # * The IP address from the internal network (in 192.168.0.0/24).
      # * The IP address from my home VPN (in 172.0.0.0/24).
      ${cfssl}/bin/cfssl gencert -profile=kubernetes -ca ${secretsPath}/ca.pem \
        -ca-key /tmp/ca-key.pem -config "${caConfig}" "-hostname=$HOSTNAME,127.0.0.1,10.0.0.1,${config.homelab.kubesServerIp},$ADDRESSES" \
        $CSR_FILE | ${cfssl}/bin/cfssljson -bare $CERTNAME
      ${openssl}/bin/openssl verify -CAfile ${secretsPath}/ca.pem $CERTNAME.pem
    ''
  );

  # Generate a certificate meant for a control node
  kubesGenControlCerts = pkgs.writers.writeBashBin "kubes-gen-control-certs" (
    with pkgs;
    ''
      set -ex

      HOSTNAME=$1
      if [ -z "$1" ]; then
        echo Hostname argument is missing
        exit 1
      fi
      ADDRESSES=$2
      if [ -z "$2" ]; then
        echo IP Addresses argument is missing
        exit 1
      fi

      trap kubes-unload-ca-cert EXIT
      kubes-load-ca-cert

      ${openssl}/bin/openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out ./apiserver-account-privkey.pem
      ${openssl}/bin/openssl pkey -in ./apiserver-account-privkey.pem -pubout -out ./apiserver-account-pubkey.pem
      kubes-gen-cert $HOSTNAME $ADDRESSES admin ${certCsr "admin" "system:masters"}
      kubes-gen-cert $HOSTNAME $ADDRESSES apiserver ${componentCsr "apiserver"}
      kubes-gen-cert $HOSTNAME $ADDRESSES controller-manager ${componentCsr "controller-manager"}
      kubes-gen-cert $HOSTNAME $ADDRESSES etcd ${componentCsr "etcd"}
      kubes-gen-cert $HOSTNAME $ADDRESSES flannel ${certCsr "system:flannel" "system:nodes"}
      cp ${certCsr "system:node:XXX" "system:nodes"} /tmp/node-cert.csr
      chmod 664 /tmp/node-cert.csr
      sed -i s/XXX/$1/g /tmp/node-cert.csr
      kubes-gen-cert $HOSTNAME $ADDRESSES kubelet /tmp/node-cert.csr
      kubes-gen-cert $HOSTNAME $ADDRESSES proxy ${componentCsr "proxy"}
      kubes-gen-cert $HOSTNAME $ADDRESSES scheduler ${componentCsr "scheduler"}
    ''
  );

  # Generate all the certificates a worker node needs
  kubesGenWorkerCerts = pkgs.writers.writeBashBin "kubes-gen-worker-certs" (
    with pkgs;
    ''
      set -ex

      HOSTNAME=$1
      if [ -z "$1" ]; then
        echo Hostnames argument is missing
        exit 1
      fi
      ADDRESSES=$2
      if [ -z "$2" ]; then
        echo IP Addresses argument is missing
        exit 1
      fi

      trap kubes-unload-ca-cert EXIT
      kubes-load-ca-cert

      kubes-gen-cert $HOSTNAME $ADDRESSES admin ${certCsr "admin" "system:masters"}
      kubes-gen-cert $HOSTNAME $ADDRESSES flannel ${certCsr "system:flannel" "system:nodes"}
      cp ${certCsr "system:node:XXX" "system:nodes"} /tmp/node-cert.csr
      chmod 664 /tmp/node-cert.csr
      sed -i s/XXX/$1/g /tmp/node-cert.csr
      kubes-gen-cert $HOSTNAME $ADDRESSES kubelet /tmp/node-cert.csr
      kubes-gen-cert $HOSTNAME $ADDRESSES proxy ${componentCsr "proxy"}
    ''
  );

  # Deploy all the control node's certificates
  kubesDeployControlCerts = pkgs.writers.writeBashBin "kubes-deploy-control-certs" (
    with pkgs;
    ''
      set -ex

      function deploy() {
        ${openssh}/bin/scp ./$2.pem "$1:~/.certs/$2.pem"
      }

      function deploy-pair() {
        deploy $1 $2
        deploy $1 $2-key
      }

      ${openssh}/bin/ssh $1 "mkdir -p ~/.certs"
      ${openssh}/bin/scp "${secretsPath}/ca.pem" "$1:~/.certs/ca.pem"
      deploy $1 apiserver-account-privkey
      deploy $1 apiserver-account-pubkey
      deploy-pair $1 admin
      deploy-pair $1 apiserver
      deploy-pair $1 controller-manager
      deploy-pair $1 etcd
      deploy-pair $1 flannel
      deploy-pair $1 kubelet
      deploy-pair $1 proxy
      deploy-pair $1 scheduler
    ''
  );

  # Deploy all the worker node's certificates
  kubesDeployWorkerCerts = pkgs.writers.writeBashBin "kubes-deploy-worker-certs" (
    with pkgs;
    ''
      set -ex

      function deploy() {
        ${openssh}/bin/scp ./$2.pem "$1:~/.certs/$2.pem"
      }

      function deploy-pair() {
        deploy $1 $2
        deploy $1 $2-key
      }

      ${openssh}/bin/ssh $1 "mkdir -p ~/.certs"
      ${openssh}/bin/scp "${secretsPath}/ca.pem" "$1:~/.certs/ca.pem"
      deploy-pair $1 admin
      deploy-pair $1 flannel
      deploy-pair $1 kubelet
      deploy-pair $1 proxy
    ''
  );
in
{
  imports = [
    ./scripts.nix
  ];

  environment.systemPackages = [
    kubesDeployControlCerts
    kubesDeployWorkerCerts
    kubesGenCaCert
    kubesGenCert
    kubesGenControlCerts
    kubesGenWorkerCerts
    kubesLoadCaCert
    kubesUnloadCaCert
  ];
}
