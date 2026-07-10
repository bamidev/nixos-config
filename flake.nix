{
  description = "Your flake description...";

  inputs = {
    # Take all editor-related packages from the previous release, so that they don't regularely update and accidentally break
    editorPkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    homeManager.url = "github:nix-community/home-manager/release-26.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      ...
    }@inputs:
    # Each directory in /etc/nixos/devices specifies parameters and hardware configuration for each of my devices.
    let
      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = lib.attrsets.mapAttrs (
        name: type:
        lib.nixosSystem {
          system = builtins.currentSystem;
          specialArgs = {
            inherit inputs;
            params = import "/etc/nixos/devices/${name}/params.nix";
            hostName = name;
          };
          modules = [
            ./base.nix
            "/etc/nixos/devices/${name}/hardware.nix"
            "/etc/nixos/devices/${name}/configuration.nix"
          ];
        }
      ) (builtins.readDir /etc/nixos/devices);

      # Add a devShell that provides nixfmt for formatting
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.nixfmt-tree ];
        };
      }
    );
}
