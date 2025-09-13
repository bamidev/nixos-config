{ pkgs, ... }:
{
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
      # Overwrite the max line length to align with Therp's standard
      ".config/nvim/after/ftplugin/python.lua".text = ''
        vim.opt.textwidth = 100
      '';
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
