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

        # Testrun an image with the command: test-image name port
        testImageScript = pkgs.writers.writeBashBin "test-image" ''
          set -ex
          nix build .#$1
          docker container rm $1 1>/dev/null || true
          docker image rm $1 1>/dev/null || true
          docker tag $(docker load -i ./result --quiet | cut -d ' ' -f 3) $1
          docker run -p $2:$2 -i -t -l $1 $1
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.nixfmt-tree
            testImageScript
          ];
        };

        # All container images are provided as the flake's packages
        packages = import lab/pods.nix { pkgs = pkgs; };
      }
    );
}
