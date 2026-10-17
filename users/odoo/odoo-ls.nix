# TODO: Contribute this nix module to nixpkgs
{ pkgs, ... }:
let
  odooLs = pkgs.rustPlatform.buildRustPackage rec {
    pname = "odoo-ls";
    version = "1.5.2";
    cargoHash = "sha256-p4E+VIKHsftD8kMUt+2icPZTAUEwLL0lIVD+h5a/eFy=";

    src = pkgs.fetchFromGitHub {
      owner = "odoo";
      repo = "odoo-ls";
      rev = version;
      hash = "sha256-Lo8WqPsEWIFRO4Gqgpuy0W4by8L5GUG6QqKxv/jdyO8=";
      fetchSubmodules = true;
    };

    cargoLock = {
      lockFile = ./odoo-ls/Cargo.lock;
      outputHashes = {
        "lsp-server-0.7.8" = "sha256-M+bLCsYRYA7iudlZkeOf+Azm/1TUvihIq51OKia6KJ8=";
        "ruff_python_ast-0.0.0" = "sha256-Q3xujVNv5i3mgdsjnvgTiPoKmK9aeSgz+2IoVrNur4k=";
        "oxc-0.127.0" = "sha256-1FQWDHE/g3QSP0wou6ACDuJrpH+e6QV8qIGO6S0fr3M=";
      };
    };

    # Many unit tests are still failing,
    # can't seem to make them work...
    doCheck = false;

    # The `test_template_varable_expansion_userhome_and_workspacefolder` unit test wants to create files & folders in the home directory.
    # Lets not do that... ;)
    env = {
      COMMUNITY_PATH = "/build/community";
      HOME = "/build/test";
    };

    nativeBuildInputs = with pkgs; [ python3 ];

    postPatch = ''
      ln -sf ${./odoo-ls/Cargo.lock} Cargo.lock
    '';

    preBuild = ''
      mkdir -p /build/{community,test}
    '';

    sourceRoot = "${src.name}/server";
  };
in
{
  home.packages = [ odooLs ];
}
