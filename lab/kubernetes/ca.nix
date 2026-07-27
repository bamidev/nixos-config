# When this module is included in the device configuration, you will have an assortment of scripts
# available at your command to generate - and deploy all the certificates needed for a kubernetes
# node.
{ config, pkgs, ... }:
let
  secretsPath = "${config.services.kubernetes.secretsPath}";

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

  scripts = [
    # This script generates a new Kubernetes root CA certificate, and stores it into the pass store.
    (pkgs.writers.writeBashBin "kubes-gen-ca-cert" (
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
    ))

    # Call this from any script that needs to access the root certificate
    (pkgs.writers.writeBashBin "kubes-load-ca-cert" ''
      set -e
      pass homelab/ca/ca-cert > ${secretsPath}/ca.pem
      pass homelab/ca/ca-key > /tmp/ca-key.pem
      chmod 1600 /tmp/ca-key.pem
    '')

    # Call this when you have called `kubes-load-ca-cert`, at the end of your script
    (pkgs.writers.writeBashBin "kubes-unload-ca-cert" (
      with pkgs;
      ''
        set -e
        if [ -f /tmp/ca-key.pem ]; then
          ${busybox}/bin/shred -u /tmp/ca-key.pem
        fi
      ''
    ))

    (pkgs.writers.writeBashBin "kubes-gen-control-cert" (
      with pkgs;
      ''
        set -ex
        ${cfssl}/bin/cfssl gencert -profile=kubernetes -ca ${secretsPath}/ca.pem \
          -ca-key /tmp/ca-key.pem -config "${caConfig}" "-hostname=$1,10.0.0.1,${config.homelab.kubesServerIp},$2,${config.homelab.kubesVpnServerIp}" \
          $4 | ${cfssl}/bin/cfssljson -bare $3
        ${openssl}/bin/openssl verify -CAfile ${secretsPath}/ca.pem $3.pem
      ''
    ))

    # Generate a certificate meant for a worker node
    (pkgs.writers.writeBashBin "kubes-gen-worker-cert" (
      with pkgs;
      ''
        set -ex
        ${cfssl}/bin/cfssl gencert -profile=kubernetes -ca ${secretsPath}/ca.pem \
          -ca-key /tmp/ca-key.pem -config "${caConfig}" "-hostname=$1,${config.homelab.kubesServerIp},$2" \
          $4 | ${cfssl}/bin/cfssljson -bare $3
        ${openssl}/bin/openssl verify -CAfile ${secretsPath}/ca.pem $3.pem
      ''
    ))

    # Generate a certificate meant for a control node
    (pkgs.writers.writeBashBin "kubes-gen-control-certs" (
      with pkgs;
      ''
        set -ex

        if [ -z "$1" ]; then
          echo Hostname argument is missing.
        fi
        IP_ADDRESS=$2
        if [ -z "$IP_ADDRESS" ]; then
          IP_ADDRESS="${config.homelab.controlNode.one.ip}"
        fi

        trap kubes-unload-ca-cert EXIT
        kubes-load-ca-cert

        ${openssl}/bin/openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out ./apiserver-account-privkey.pem
        ${openssl}/bin/openssl pkey -in ./apiserver-account-privkey.pem -pubout -out ./apiserver-account-pubkey.pem
        kubes-gen-control-cert $1 $IP_ADDRESS admin ${certCsr "admin" "system:masters"}
        kubes-gen-control-cert $1 $IP_ADDRESS apiserver ${componentCsr "apiserver"}
        kubes-gen-control-cert $1 $IP_ADDRESS controller-manager ${componentCsr "controller-manager"}
        kubes-gen-control-cert $1 $IP_ADDRESS etcd ${componentCsr "etcd"}
        kubes-gen-control-cert $1 $IP_ADDRESS flannel ${certCsr "system:flannel" "system:nodes"}
        cp ${certCsr "system:node:XXX" "system:nodes"} /tmp/node-cert.csr
        sed -i s/XXX/$1/g /tmp/node-cert.csr
        kubes-gen-control-cert $1 $IP_ADDRESS kubelet /tmp/node-cert.csr
        kubes-gen-control-cert $1 $IP_ADDRESS proxy ${componentCsr "proxy"}
        kubes-gen-control-cert $1 $IP_ADDRESS scheduler ${componentCsr "scheduler"}
      ''
    ))

    # Generate all the certificates a worker node needs
    (pkgs.writers.writeBashBin "kubes-gen-worker-certs" (
      with pkgs;
      ''
        set -ex

        if [ -z "$1" ]; then
          echo Hostname argument is missing.
        fi
        if [ -z "$2" ]; then
          echo IP address argument is missing.
        fi

        trap kubes-unload-ca-cert EXIT
        kubes-load-ca-cert

        kubes-gen-worker-cert $1 $2 admin ${certCsr "admin" "system:masters"}
        kubes-gen-worker-cert $1 $2 flannel ${certCsr "system:flannel" "system:nodes"}
        # TODO: Replace old-laptop1 with a way to put $1 into it (maybe be replacing it?)
        kubes-gen-worker-cert $1 $2 kubelet ${certCsr "system:node:old-laptop2" "system:nodes"}
        kubes-gen-worker-cert $1 $2 proxy ${componentCsr "proxy"}
      ''
    ))

    # Deploy all the control node's certificates
    (pkgs.writers.writeBashBin "kubes-deploy-control-certs" (
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
    ))

    # Deploy all the worker node's certificates
    (pkgs.writers.writeBashBin "kubes-deploy-worker-certs" (
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
    ))
  ];
in
{
  environment.systemPackages = scripts;
}
