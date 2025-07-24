{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    syncstorage-rs
  ];
}
