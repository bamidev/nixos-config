{ pkgs }:
let
  testImageScript = pkgs.writers.writeBashBin "test-image" ''
    set -ex
    nix build .#$1
    docker container rm $1 1>/dev/null || true
    docker image rm $1 1>/dev/null || true
    docker tag $(docker load -i ./result --quiet | cut -d ' ' -f 3) $1
    docker run -p $2:$2 -i -t -l $1 $1
  '';
in
[
  testImageScript
]
