# Disable WiFi during sleeptime
{ pkgs, ... }:
{
  services = {
    cron = {
      enable = true;
      systemCronJobs = [
        "0 22 * * * root ${pkgs.util-linux}/bin/rfkill block wifi"
        "0  9 * * * root ${pkgs.util-linux}/bin/rfkill unblock wifi"
      ];
    };
  };
}
