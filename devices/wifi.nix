# Disable WiFi during sleeptime
{ pkgs, ... }:
{
  services = {
    cron = {
      enable = true;
      systemCronJobs = [
        "0  22 * * * root ${pkgs.util-linux}/bin/rfkill block wifi"
        "0  9  * * * root ${pkgs.util-linux}/bin/rfkill unblock wifi"
        "10 9  * * * root ${pkgs.iputils}/bin/ping -c 4 172.0.0.100"
      ];
    };
  };
}
