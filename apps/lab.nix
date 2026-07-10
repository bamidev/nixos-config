{ pkgs, ... }: {
  services = {
    cron = {
      enable = true;
      systemCronJobs = [
        "0 22 * * * root ${pkgs.util-linux}/bin/rfkill block wifi"
        "0 9 * * * root ${pkgs.util-linux}/bin/rfkill unblock wifi"
      ];
    };

    logind.lidSwitch = "ignore";
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };
}
