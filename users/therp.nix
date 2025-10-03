{ pkgs, lib, ... }:
let
  odooParams = import ./therp/odoo-params.nix;
  nixpkgsPython = (builtins.getFlake "github:cachix/nixpkgs-python").packages.${builtins.currentSystem};
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
      ".config/nvim/lua/init-odoo.lua".text = import ./therp/nvim-init-odoo.nix {
        pkgs=pkgs;
        lib=lib;
      };

      ".config/pylintrc".text = builtins.readFile ../apps/neovim/etc/pylintrc + ''

        [VARIABLES]
        additional-builtins = env
      '';

      # Ignore docstring warnings because they are rarely used within Odoo code.
      ".pydocstyle.ini".text = ''
        [pydocstyle]
        ignore = D100,D101,D102
      '';

      # Max line length is actually 88 although it is not configured everywhere
      ".config/pycodestyle".text = ''
        [pycodestyle]
        ignore = W503
        max-line-length = 88
      '';

      "odools.toml".text = ''
        [[config]]
        name = "setup-base"
        stdlib = "/home/therp/lsp/odoo/odoo-ls/server/typeshed/stdlib/"
        addons_paths = ["''${workspaceFolder}"]

      '' + lib.strings.concatStrings (lib.lists.forEach (
        lib.range odooParams.lspVersions.start odooParams.lspVersions.stop
      ) (majorVersion: ''
        [[config]]
        name = "setup-${toString majorVersion}.0"
        extends = "setup-base"
        odoo_path = "/home/therp/lsp/odoo/${toString majorVersion}.0/wax/repos/odoo/"
        python_path = "/home/therp/lsp/odoo/${toString majorVersion}.0/wax/venv/bin/python"
        addons_paths = ["/home/therp/lsp/odoo/${toString majorVersion}.0/wax/addons"]

      ''));
    } // lib.attrsets.genAttrs (lib.lists.forEach ["16.0"] (v: "lsp/odoo/${v}/flake.nix.example")) (version:
      {
        text = ''
          {
            inputs = {
              wax.url = "github:bamidev/wax";
            };

            outputs = { self, wax }: {
              devShells.${builtins.currentSystem}.default = wax.lib.mkOdooShell {
                system = "${builtins.currentSystem}";
                config =  {
                  odooVersion = "${version}";

                  repos.spec = {
                    odoo = {};
                  };
                };
              };
            };
          }
        '';
      }
    );

    packages = with pkgs; [
      black
    ] ++ [
      installPreCommit
      preCommit
      sst
    ];
  };

  programs = {
    firefox.policies = {
      Cookies.Allow = ["https://therp.nl"];
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
