{ pkgs, config, ... }: {
  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${config.programs.sway.package}/bin/sway";
      };
    };
  };
}
