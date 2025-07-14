{ ... }: {
  services = {
    logind.lidSwitch = "ignore";

    openssh = {
      enable = true;
    };
  };
}
