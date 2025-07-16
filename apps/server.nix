{ pkgs, ... }: {
  services = {
    cron = {
      enable = true;
      systemCronJobs = [
        "0 22 * * * root ${pkgs.iproute2}/bin/ip link set wlp2s0 down'"
        "0 9 * * * root ${pkgs.iproute2}/bin/ip link set wlp2s0 up'"
      ];
    };

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
