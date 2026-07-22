{ pkgs }:
let
  # A script to test an image locally using docker
  testImageScript = pkgs.writers.writeBashBin "test-image" ''
    set -ex
    nix build -o /tmp/result .#$1 --show-trace
    docker container rm $1 1>/dev/null || true
    docker image rm $1 1>/dev/null || true
    docker tag $(docker load -i /tmp/result --quiet | cut -d ' ' -f 3) $1
    docker run -p $2:$2 -i -t -l $1 $1
  '';

  # A script to build & deploy an image to my cluster
  loadImageScript = pkgs.writers.writeBashBin "deploy-image" ''
    set -ex

    HOST=$2
    if [ -z "$HOST" ]; then
      HOST="myvpn-old-laptop-asus"
    fi

    nix build -o /tmp/result .#$1
    scp /tmp/result $HOST:/tmp/image
    ssh $HOST chmod +w /tmp/image
    ssh -t $HOST "sudo /run/current-system/sw/bin/ctr -n k8s.io images prune --all"
    IMAGE_ABBREV=$(ssh -t $HOST "sudo /run/current-system/sw/bin/ctr -n k8s.io images \
      import /tmp/image" | head -n 1 | cut -d ':' -f 2 | head -c 8)
    IMAGE_ID=$(ssh -t $HOST "sudo /run/current-system/sw/bin/ctr -n k8s.io images list | grep \
      $IMAGE_ABBREV | head -n 1 | cut -d ' ' -f 1" | tr -d '\r')
    ssh -t $HOST "sudo /run/current-system/sw/bin/ctr -n k8s.io images tag $IMAGE_ID docker.io/library/$1:latest"
  '';
in
[
  loadImageScript
  testImageScript
]
