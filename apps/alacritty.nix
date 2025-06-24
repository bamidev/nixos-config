{
  programs.alacritty.enable = true;

  home.file.".config/alacritty/alacritty.toml".text = '' 
    [font]
    builtin_box_drawing = true
    size = 12

    [[hints.enabled]]
    command = { program = "vi", args = [ "+" ] }
    mouse = { enabled = true }
    regex = "[^ ]+\\.rs:\\d+:\\d+"
  '';
}
