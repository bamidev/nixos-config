rec {
  defaultVersioning = {
    type = "staggered";
    params = {
      cleanInterval = "3600";
      keep = "5";
      maxAge = "157680000"; # About 5 years
    };
  };
  devices = [
    "main-laptop"
    "desktop"
    "nas"
  ];
  defaultFolder = {
    devices = devices;
    ignorePerms = false;
    versioning = defaultVersioning;
  };
}
