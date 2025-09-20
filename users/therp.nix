{ pkgs, lib, ... }:
let
  odooParams = import ./therp/odoo-params.nix;
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

      ".pydocstyle.ini".text = ''
        [pydocstyle]
        ignore = D100
      '';

      "odools.toml".text = ''
        [[config]]
        name = "setup-base"
        stdlib = "/home/therp/lsp/odoo/odoo-ls/server/typeshed/stdlib/"

      '' + lib.strings.concatStrings (lib.lists.forEach (
        lib.range odooParams.lspVersions.start odooParams.lspVersions.stop
      ) (majorVersion: ''
        [[config]]
        name = "setup-${toString majorVersion}.0"
        extends = "setup-base"
        odoo_path = "/home/therp/lsp/odoo/${toString majorVersion}.0/odoo/"
        addons_paths = [
      '' +
        lib.strings.concatStrings (lib.lists.forEach odooParams.lspOcaRepos (repo:
          "\"/home/therp/lsp/odoo/${toString majorVersion}.0/${repo}\","
        )) + '']

      ''));
    };

    packages = with pkgs; [
      black
      pre-commit
    ];
  };

  programs = {
    firefox.policies.Cookies.Allow = ["https://therp.nl"];

    git = {
      userName = "Danny de Jong";
      userEmail = "ddejong@therp.nl";
    };

    ssh = {
      enable = true;

      extraConfig = "Include ~/.ssh/config.d/*.conf";
    };
  };
}
