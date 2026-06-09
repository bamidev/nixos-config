{
  description = "Your flake description...";

  inputs = {
    # Take all editor-related packages from the previous release, so that they don't regularely update and accidentally break
    editorPkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    homeManager.url = "github:nix-community/home-manager/release-26.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    # Each directory in /etc/nixos/devices specifies parameters and hardware configuration for each of my devices.
    let
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = lib.attrsets.mapAttrs(name: type: lib.nixosSystem {
        system = builtins.currentSystem;
        specialArgs = {
          inherit inputs;
          params = import "/etc/nixos/devices/${name}/params.nix";
          hostName = name;
        };
        modules = [
          ./configuration.nix
          "/etc/nixos/devices/${name}/hardware.nix"
        ];
      }) (builtins.readDir /etc/nixos/devices);
    };
} 
