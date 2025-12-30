{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    libreoffice
    hunspell
    hunspellDicts.nl_NL
    hunspellDicts.en_GB-large
    hunspellDicts.en_US-large
  ];
}
