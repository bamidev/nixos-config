{ pkgs, config, ... }: {
  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd sway";
      };
    };
  };

  environment.etc."greetd/environments".text = ''
    bash
    hyprland
    sway
  '';
}
