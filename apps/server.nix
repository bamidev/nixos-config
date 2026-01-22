{ pkgs, ... }: {
  services = {
    cron = {
      enable = true;
      systemCronJobs = [
        "0 22 * * * ${pkgs.util-linux}/bin/rfkill block wifi"
        "0 9 * * * ${pkgs.util-linux}/bin/rfkill unblock wifi"
      ];
    };

    logind.lidSwitch = "ignore";
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';
}
