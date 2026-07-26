{
  description = "The NixOS configuration for all my devices, incluing my work-laptop, gaming pc, and my home-lab Kubernetes cluster.";

  inputs = {
    # Take all editor-related packages from the previous release, so that they don't regularely update and accidentally break
    editorPkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    homeManager.url = "github:nix-community/home-manager/release-26.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      nixosConfigurations =
        lib.attrsets.mapAttrs
          (
            name: type:
            let
              params = import "/etc/nixos/devices/${name}/params.nix";
            in
            lib.nixosSystem {
              system = params.system;
              specialArgs = {
                inherit inputs;
                inherit params;
                hostName = name;
              };
              modules = [
                ./base.nix
                ./devices/${name}/hardware.nix
                ./devices/${name}/configuration.nix
              ];
            }
          )
          (
            lib.attrsets.filterAttrs (name: _: builtins.readFileType ./devices/${name} == "directory") (
              builtins.readDir /etc/nixos/devices
            )
          );

      # Add a devShell that provides nixfmt for formatting
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.nixfmt-tree
          ]
          ++ (import ./lab/scripts.nix { inherit pkgs; });
        };

        # All container images are provided as the flake's packages
        packages = import lab/images.nix { pkgs = pkgs; };
      }
    );
}
