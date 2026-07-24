{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  editorPkgs = inputs.editorPkgs.legacyPackages."${builtins.currentSystem}";

  odooParams = import ./therp/odoo-params.nix;
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
  sst = pkgs.writers.writeBashBin "sst" ''
    ssh -A $@ -t "export VIMINIT='
    nmap ; :
    vmap ; :
    '; bash --norc"
  '';
in
{
  imports = [
    ./desktop.nix
    ./therp/odoo-ls.nix
    ./therp/odoo-lsp.nix
  ];

  accounts.email.accounts."Therp" = rec {
    thunderbird.enable = true;

    realName = "Danny de Jong";
    address = "ddejong@therp.nl";
    userName = address;

    imap = {
      host = "imap.mailbox.org";
      port = 993;
      tls.enable = true;
    };

    smtp = {
      host = "smtp.mailbox.org";
      port = 587;
      tls.useStartTls = true;
    };
  };

  home = {
    stateVersion = "24.11";

    file = {
      ".init.sh" = {
        executable = true;
        text = ''
          export XDG_CONFIG_DIRS="/home/therp/.config/xdg-global:$XDG_CONFIG_DIRS"
        '';
      };

      ".config/flake8".text = ''
        [flake8]
        builtins = env
      '';

      # Put the global xdg configuration files in a local path, so that they may be available in a
      # FHSEnv as well.
      ".config/xdg-global" = {
        recursive = true;
        source = /etc/xdg;
      };
      ".config/nvim" = {
        recursive = true;
        source = ./therp/nvim;
      };
      ".config/nvim/init.lua" = lib.mkForce {
        text = ''
          vim.cmd('luafile ~/.config/xdg-global/nvim/init.lua')
          require('therp-init')
        '';
      };

      # Allow raising broad exceptions, because many times migration scripts need not to do anything
      # special to throw an error.
      # Disable filename checking because migration scripts' filenames require an unconvential file
      # name style.
      # Disable function & module docstrings because migration scripts are not expected to have
      # them.
      # Disable pointless statements because pylint doesn't understand Odoo's manifest files
      ".config/pylintrc".text = builtins.readFile ../apps/neovim/etc/pylintrc + ''

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
        additional_stubs = ["/home/therp/lsp/odoo-ls/server/typeshed/stubs"]
        addons_paths = ["''${workspaceFolder}"]
        stdlib = "/home/therp/lsp/odoo-ls/server/typeshed/stdlib/"
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
            odoo_path = "/home/therp/wax/${toString majorVersion}.0/wax/repos/odoo/"
            python_path = "/home/therp/wax/${toString majorVersion}.0/wax/venv/bin/python"
            addons_paths = ["/home/therp/wax/${toString majorVersion}.0/wax/addons"]
            diag_missing_imports = "${if majorVersion > 14 then "only_odoo" else "none"}"

          '')
      );

      ".ssh/myconfig".text = ''
        Host odoo-ocad-lab ocad-lab
          Hostname 10.10.10.157
          User ubuntu
          ForwardAgent yes
          PermitLocalCommand yes
          ProxyCommand ssh -A -p 7458 customers-proxy-user@therp1.nl nc %h %p
      '';

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
            };

            outputs = { self, wax }: {
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
        sst
      ];

    sessionVariables = {
      WAX_CONTAINERIZED_DB = "1";
    };
  };

  programs = {
    firefox.policies = {
      Cookies.Allow = [
        "https://therp.nl"
        "https://gitlab.therp.nl"
        "https://helpdesk.therp.nl"
      ];
      ExtensionSettings = {
        "info@therp.nl" = {
          install_url = "https://github.com/Therp/odoo-timer/releases/download/1.12/therp-odoo-timer-firefox-1.12.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    git.settings = {
      user.name = "Danny de Jong";
      user.email = "ddejong@therp.nl";
    };

    ssh = {
      enable = true;

      extraConfig = ''
        Include ~/.ssh/config.d/*.conf
        Include ~/.ssh/my-config
        SendEnv VIMINIT
      '';
    };
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];
}
