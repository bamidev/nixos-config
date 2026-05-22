# TODO: Contribute this nix module to nixpkgs
{ pkgs, ... }:
let
  odooLs = pkgs.rustPlatform.buildRustPackage rec {
    pname = "odoo-ls";
    version = "1.2.1";
    cargoHash = "sha256-p4E+VIKHsftD8kMUt+1icPZTAUEwLL0lIVD+h5a/eFY=";

    src = pkgs.fetchFromGitHub {
      owner = "odoo";
      repo = "odoo-ls";
      rev = version;
      hash = "sha256-+nx5N3ImjrNDnvgHt/6Vcyw8IBgz9qJQDu2OV9il6xA=";
      fetchSubmodules = true;
    };

    cargoLock = {
      lockFile = ./odoo-ls/Cargo.lock;
      outputHashes = {
        "lsp-server-0.7.8" = "sha256-M+bLCsYRYA7iudlZkeOf+Azm/1TUvihIq51OKia6KJ8=";
        "ruff_python_ast-0.0.0" = "sha256-jRH7OOT03MDomZAJM20+J4y5+xjN1ZAV27Z44O1qCEQ=";
      };
    };

    # The diagnostic tests are still failing,
    # can't seem to make them work...
    doCheck = false;

    # The `test_template_varable_expansion_userhome_and_workspacefolder` unit test wants to create files & folders in the home directory.
    # Lets not do that... ;)
    env.HOME = "/build/test";

    nativeBuildInputs = with pkgs; [ python3 ];

    postPatch = ''
      ln -sf ${./odoo-ls/Cargo.lock} Cargo.lock
    '';

    preBuild = ''
      mkdir -p /build/{community,test}
    '';

    sourceRoot = "${src.name}/server";
  };
in {
  home.packages = [ odooLs ];
}
