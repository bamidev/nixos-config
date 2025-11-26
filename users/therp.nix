{ pkgs, lib, ... }:
let
  odooParams = import ./therp/odoo-params.nix;
  params = import ../params.nix;
  preCommitFlake = (builtins.getFlake "github:ddejong-therp/therp-pre-commit").apps.${builtins.currentSystem};

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
in {
  imports = [
    ./desktop.nix
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
      # Some work related snippets
      ".config/nvim" = {
        recursive = true;
        source = ./therp/nvim;
      };
      ".config/nvim/init.lua" = lib.mkForce {
        text = ''
          require('init-odoo')
          vim.cmd('luafile /etc/xdg/nvim/init.lua')
        '';
      };
      ".config/nvim/lua/init-odoo.lua" = lib.attrsets.optionalAttrs (params.environmentType == "desktop") {
        text = import ./therp/nvim-init-odoo.nix { pkgs=pkgs; lib=lib; };
      };

      # Disable import errors from pylint, because pylint is not aware of which Wax venv is being
      # used, and odoo-ls performs the same check while odoo-ls _is_ aware of the right venv used.
      # Disable filename checking because migration scripts' filenames require an unconvential file
      # name style.
      # Disable function & module docstrings because migration scripts are not expected to have
      # them.
      # Disable pointless statements because pylint doesn't understand Odoo's manifest files
      ".config/pylintrc".text = builtins.readFile ../apps/neovim/etc/pylintrc + ''

        [MAIN]
        disable=broad-exception-raised,import-error,invalid-name,missing-class-docstring,missing-function-docstring,missing-module-docstring,pointless-statement,too-few-public-methods

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

      "odools.toml".text = ''
        [[config]]
        name = "setup-base"
        stdlib = "/home/therp/lsp/odoo-ls/server/typeshed/stdlib/"
        addons_paths = ["''${workspaceFolder}"]

      '' + lib.strings.concatStrings (lib.lists.forEach (
        lib.range odooParams.lspVersions.start odooParams.lspVersions.stop
      ) (majorVersion: ''
        [[config]]
        name = "setup-${toString majorVersion}.0"
        extends = "setup-base"
        odoo_path = "/home/therp/wax/${toString majorVersion}.0/wax/repos/odoo/"
        python_path = "/home/therp/wax/${toString majorVersion}.0/wax/venv/bin/python"
        addons_paths = ["/home/therp/wax/${toString majorVersion}.0/wax/addons"]

      ''));
    # Create a Wax flake.nix template for each Odoo version
    } // lib.attrsets.mergeAttrsList (lib.lists.forEach (
      lib.range odooParams.lspVersions.start
      odooParams.lspVersions.stop
    ) (version: 
      {
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
                  databaseName = "odoo${toString version}";

                  repos.spec = {
                    odoo = {};
                  };
                };
              };
            };
          }
        '';

        "wax/${toString version}.0/init.sh" = {
          executable = true;
          text = ''
            #/usr/bin/env bash
            set -e
            cat > .gitignore <<HEREDOC
              init.sh
              flake.nix.example
              wax
            HEREDOC

            cp flake.nix.example flake.nix
            git init
            git add .
            git commit -m "Initial commit"
          '';
        };
      })
    );

    packages = with pkgs; [
      black
      uv
    ] ++ [
      installPreCommit
      preCommit
      sst
    ];
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

    git = {
      userName = "Danny de Jong";
      userEmail = "ddejong@therp.nl";
    };

    ssh = {
      enable = true;

      extraConfig = ''
        Include ~/.ssh/config.d/*.conf
        SendEnv VIMINIT
      '';
    };
  };
}
