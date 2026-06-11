{ pkgs, lib, ... }:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "keet"
    ];

  environment.systemPackages = with pkgs; [
    keet
  ];
}
