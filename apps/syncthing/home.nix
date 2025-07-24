{ ... }:
{
  home.file.".config/.stignore".text = ''
    !FreeTube/profiles.db
    **
  '';
}
