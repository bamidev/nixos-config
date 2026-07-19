{ pkgs }:
let
  testImageScript = pkgs.writers.writeBashBin "test-image" ''
    set -ex
    nix build -o /tmp/result .#$1 --show-trace
    docker container rm $1 1>/dev/null || true
    docker image rm $1 1>/dev/null || true
    docker tag $(docker load -i /tmp/result --quiet | cut -d ' ' -f 3) $1
    docker run -p $2:$2 -i -t -l $1 $1
  '';

  loadImageScript = pkgs.writers.writeBashBin "load-image" (with pkgs; ''
    set -ex
    nix build -o /tmp/result .#$1
    scp /tmp/result old-laptop2:/tmp/image
    ssh old-laptop2 chmod +w /tmp/image
    IMAGE_NAME=$(ssh -t old-laptop2 "sudo /run/current-system/sw/bin/ctr -n k8s.io images import /tmp/image" | grep sha256: | cut -d ' ' -f 2)
    ssh -t old-laptop2 'sudo /run/current-system/sw/bin/ctr -n k8s.io images tag "$IMAGE_NAME" $1:latest'
  '');
in
[
  loadImageScript
  testImageScript
]
