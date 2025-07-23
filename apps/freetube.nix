{ ... }:
{
  programs.freetube = { 
    enable = true;
    settings = {
      allowDashAv1Formats = true;
      checkForUpdates = false;
      defaultQuality = "240";
    };
  };
}
