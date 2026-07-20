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

  loadImageScript = pkgs.writers.writeBashBin "load-image" (
    with pkgs;
    ''
      set -ex
      nix build -o /tmp/result .#$1
      scp /tmp/result old-laptop2:/tmp/image
      ssh old-laptop2 chmod +w /tmp/image
      IMAGE_ABBREV=$(ssh -t old-laptop2 "sudo /run/current-system/sw/bin/ctr -n k8s.io images \
        import --index-name $1:latest /tmp/image" | head -n 1 | cut -d ' ' -f 1)
      IMAGE_ID=$(ssh -t old-laptop2 "sudo /run/current-system/sw/bin/ctr -n k8s.io images list | \
        head -n 2 | tail -n 1 | cut -d ' ' -f 1" | tr -d '\r')
      ssh -t old-laptop2 "sudo /run/current-system/sw/bin/ctr -n k8s.io images tag $IMAGE_ID docker.io/library/$1:latest"
    ''
  );
in
[
  loadImageScript
  testImageScript
]
