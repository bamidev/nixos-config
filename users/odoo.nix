{
  pkgs,
  lib,
  ...
}:
let
  preCommitFlake =
    (builtins.getFlake "github:ddejong-therp/therp-pre-commit").apps.${builtins.currentSystem};

  installPreCommit = pkgs.writers.writeBashBin "pc-install" ''
    set -e
    echo "pc" > .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    echo Installed the pre-commit hook.
  '';
  preCommit = pkgs.writers.writeBashBin "pc" ''
    set -e
    ${preCommitFlake.default.program}
  '';
in
{
  imports = [
    ./desktop.nix
    ./odoo/common.nix
    ./odoo/odoo-ls.nix
    ./odoo/odoo-lsp.nix
  ];

  # Install my pre-commit wrapper that tends to work with OCA pre-commit configs
  home.packages = [
    installPreCommit
    pkgs.claude-code
    preCommit
  ];

  programs = {
    git.settings = {
      user.name = "Bamidev";
      user.email = "bamidev@pm.me";
    };
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];
}
