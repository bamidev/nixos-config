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
      ".config/nvim/ftplugin/after/python.lua".text = ''
        vim.o.textwidth = 99
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
