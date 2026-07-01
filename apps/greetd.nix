{ pkgs, ... }: {
  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd start-hyprland";
      };
    };

    useTextGreeter = true;
  };

  environment.etc."greetd/environments".text = ''
    bash
    hyprland
    sway
  '';
}
