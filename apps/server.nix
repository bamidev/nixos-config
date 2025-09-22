{ pkgs, ... }: {
  services = {
    cron = {
      enable = true;
      systemCronJobs = [
        "0 22 * * * ${pkgs.iproute2}/bin/ip link set wlp2s0 down'"
        "0 9 * * * ${pkgs.iproute2}/bin/ip link set wlp2s0 up'"
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
