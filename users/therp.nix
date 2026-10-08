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
    ./odoo/common.nix
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
    file = {
      ".ssh/myconfig".text = ''
        Host odoo-ocad-lab ocad-lab
          Hostname 10.10.10.157
          User ubuntu
          ForwardAgent yes
          PermitLocalCommand yes
          ProxyCommand ssh -A -p 7458 customers-proxy-user@therp1.nl nc %h %p
      '';

      # The env variable is provided globally in Python migration script for Waft's migration
      # framework.
      ".config/flake8".text = ''
        [flake8]
        builtins = env
      '';
    };

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
