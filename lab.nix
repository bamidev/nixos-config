{ ... }:
{
  # An unaccessible dir for storing plain passwords for when there is no other way to keep things
  # declarative.
  systemd.tmpfiles.rules = [ "d /root/.password 1600 root root -" ];
}
