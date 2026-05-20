{ pkgs, ... }:
let
  odooLsp = pkgs.rustPlatform.buildRustPackage rec {
    pname = "odoo-lsp";
    version = "0.6.2";
    cargoHash = "sha256-p4E+VIKHsftD8kMUt+1icPZTAUEwLL0lIVD+h5a/eFY=";

    src = pkgs.fetchCrate {
      inherit pname version;
      hash = "sha256-VDoLeZ31jzjKWoR6QmWgkQDVe8fXW4BmxZkMJmb5/YU=";
    };

    nativeBuildInputs = with pkgs; [ git ];

    preBuild = ''
      # A workaround to make compilation work.
      # odoo-lsp uses the git_version call, which inevitably invokes `git describe` on the repo, which won't work because the .git folder is removed by Nix.
      # So lets create a new git repo that contains the version tag that the git_version crate is looking for.
      git init
      git add -A
      git config user.email "nix@build.xxx"
      git config user.name "Nix Build"
      git commit -m "commit"
      git tag v${version}
    '';
  };
in {
  home.packages = [ odooLsp ];
}
