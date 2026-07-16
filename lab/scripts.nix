{ pkgs }:
let
  testImageScript = pkgs.writers.writeBashBin "test-image" ''
    set -ex
    nix build -o /tmp/result .#$1
    docker container rm $1 1>/dev/null || true
    docker image rm $1 1>/dev/null || true
    docker tag $(docker load -i /tmp/result --quiet | cut -d ' ' -f 3) $1
    docker run -p $2:$2 -i -t -l $1 $1
  '';
  loadImageScript = pkgs.writers.writeBashBin "load-image" (with pkgs; ''
    set -ex
    nix build -o /tmp/result .#$1
    $IMAGE_NAME=$(${containerd}/bin/ctr -n k8s.io images import /tmp/result | grep sha256: | cut -d ' ' -f 2)
    ${containerd}/bin/ctr -n k8s.io images tag "$IMAGE_NAME" $1:latest
  '');
in
[
  loadImageScript
  testImageScript
]
