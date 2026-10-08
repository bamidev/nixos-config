{
  config,
  pkgs,
  lib,
  ...
}:
let
  odooParams = import ./odoo-params.nix;
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
    ../desktop.nix
    ./odoo-ls.nix
    ./odoo-lsp.nix
  ];

  home = {
    stateVersion = "24.11";

    file = {
      ".init.sh" = {
        executable = true;
        text = ''
          export XDG_CONFIG_DIRS="~/.config/xdg-global:$XDG_CONFIG_DIRS"
        '';
      };

      # Put the global xdg configuration files in a local path, so that they may be available in a
      # FHSEnv as well.
      ".config/xdg-global" = {
        recursive = true;
        source = /etc/xdg;
      };
      # Add some additional Neovim config files to override or extend the global configuration
      ".config/nvim" = {
        recursive = true;
        source = ./nvim;
      };
      ".config/nvim/init.lua" = lib.mkForce {
        text = ''
          vim.cmd('luafile ~/.config/xdg-global/nvim/init.lua')
          require('odoo-init')
        '';
      };

      # Allow raising broad exceptions, because many times migration scripts need not do anything
      # special to throw an error.
      # Disable filename checking because migration scripts' filenames require an unconventional
      # file name style.
      # Disable function & module docstrings because migration scripts are not expected to have
      # them, and it is uncommon for Odoo modules.
      # Disable pointless statements because pylint doesn't understand Odoo's manifest files
      ".config/pylintrc".text = builtins.readFile ../../apps/neovim/etc/pylintrc + ''

        [MAIN]
        disable=broad-exception-raised,invalid-name,missing-class-docstring,missing-function-docstring,missing-module-docstring,pointless-statement,too-few-public-methods,unknown-option-value

        [VARIABLES]
        additional-builtins = env
      '';

      # Ignore docstring warnings because they are rarely used within Odoo code.
      ".pydocstyle.ini".text = ''
        [pydocstyle]
        ignore = D100,D101,D102,D103,D104,D212
      '';

      # Max line length is actually 88 although it is not configured everywhere
      ".config/pycodestyle".text = ''
        [pycodestyle]
        ignore = W503,W504
        max-line-length = 88
      '';

      ".config/odools.toml".text = ''
        [[config]]
        name = "setup-base"
        additional_stubs = ["${config.home.homeDirectory}/lsp/odoo-ls/server/typeshed/stubs"]
        addons_paths = ["''${workspaceFolder}"]
        stdlib = "${config.home.homeDirectory}/lsp/odoo-ls/server/typeshed/stdlib/"
        diagnostic_settings = {
          "OLS01001" = "Disabled" # A bug appears to exist that gives this warning while nothing is wrong.
        }

      ''
      + lib.strings.concatStrings (
        lib.lists.forEach (lib.range odooParams.lspVersions.start odooParams.lspVersions.stop)
          (majorVersion: ''
            [[config]]
            name = "setup-${toString majorVersion}.0"
            extends = "setup-base"
            odoo_path = "${config.home.homeDirectory}/wax/${toString majorVersion}.0/wax/repos/odoo/"
            python_path = "${config.home.homeDirectory}/wax/${toString majorVersion}.0/wax/venv/bin/python"
            addons_paths = ["${config.home.homeDirectory}/wax/${toString majorVersion}.0/wax/addons"]
            diag_missing_imports = "${if majorVersion > 14 then "only_odoo" else "none"}"

          '')
      );

      ".config/ruff.toml" = lib.mkForce {
        text = ''
          extend = "/etc/ruff.toml"

          builtins = ["env"]
        '';
      };
      # Create a Wax flake.nix template for each Odoo version
    }
    // lib.attrsets.mergeAttrsList (
      lib.lists.forEach (lib.range odooParams.lspVersions.start odooParams.lspVersions.stop) (version: {
        "wax/${toString version}.0/flake.nix.example".text = ''
          {
            inputs = {
              wax.url = "github:bamidev/wax";
              nixpkgs.follows = "wax/nixpkgs";
            };

            outputs = { self, wax, nixpkgs }:
              let 
                pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};
              in
              {
                devShells.${builtins.currentSystem}.default = wax.lib.mkOdooShell {
                  system = "${builtins.currentSystem}";
                  config =  {
                    odooVersion = "${toString version}.0";
                    database.allow_containerization = true;

                    repos.spec = {
                      odoo = {};

                      account-analytic = {};
                      account-financial-reporting = {};
                      account-financial-tools = {};
                      account-invoicing = {};
                      account-reconcile = {};
                      bank-payment = {};
                      bank-statement-import = {};
                      community-data-files = {};
                      contract = {};
                      credit-control = {};
                      currency = {};
                      edi = {};
                      hr = {};
                      hr-holidays = {};
                      timesheet = {};
                      intrastat = {};
                      knowledge = {};
                      l10n-netherlands = {};
                      mis-builder = {};
                      odoo-pim = {};
                      OpenUpgrade = {};
                      partner-contact = {};
                      project = {};
                      queue = {};
                      reporting-engine = {};
                      sale-workflow = {};
                      server-auth = {};
                      server-backend = {};
                      server-brand = {};
                      server-env = {};
                      server-tools = {};
                      server-ux = {};
                      sign = {};
                      social = {};
                      web = {};
                      website = {};
                    };
                  };
                };
              };
          }
        '';

        "wax/${toString version}.0/.envrc".text = "use flake";

        "wax/${toString version}.0/init.sh" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            set -e
            if [ -f flake.nix ]; then
              echo flake.nix already exists, doing nothing.
              false
            fi

            cat > .gitignore <<HEREDOC
            init.sh
            flake.nix.example
            wax
            .direnv
            HEREDOC

            cp flake.nix.example flake.nix
            git init
            git add .
            git commit -m "Initial commit"
          '';
        };
      })
    );

    packages =
      with pkgs;
      [
        claude-code
      ]
      ++ [
        installPreCommit
        preCommit
      ];

    sessionVariables = {
      WAX_CONTAINERIZED_DB = "1";
    };
  };
}
