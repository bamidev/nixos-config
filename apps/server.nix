{ ... }: {
  services = {
    logind.lidSwitch = "ignore";

    openssh = {
      enable = true;
    };
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';
}
