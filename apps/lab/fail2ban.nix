# A very basic fail2ban setup for now.
# NixOS comes with a default sshd jail.
{ ... }:
{
  services = {
    fail2ban = {
      enable = true;

      bantime = "24h";
      bantime-increment = {
        enable = true;
        multipliers = "1 8 64";
        overalljails = true;
      };
      maxretry = 5;
      ignoreIP = [
        "10.0.0.0/8"
        "172.0.0.0/24"
      ];
    };

    openssh.settings.LogLevel = "VERBOSE";
  };
}
