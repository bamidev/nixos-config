{ ... }: {
  services.evremap = {
    enable = true;

    settings = {
      device_name = "foostan Corne v4";
      remap = [
        /*{
          input = ["KEY_SEMICOLON"];
          output = ["KEY_LEFTSHIFT" "KEY_SEMICOLON"];
        }
        {
          input = ["KEY_LEFTSHIFT" "KEY_SEMICOLON"];
          output = ["KEY_SEMICOLON"];
        }*/
      ];
    };
  };
}
