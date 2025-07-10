let
  theme = import ../theme.nix;
in {
  programs.alacritty.enable = true;

  home.file = {
    ".config/alacritty/alacritty.toml".text = ''
      [general]
      import = [
        "theme.toml"
      ]

      [font]
      builtin_box_drawing = true
      size = 12.5

      [[hints.enabled]]
      command = { program = "vi", args = [ "+" ] }
      mouse = { enabled = true }
      regex = "[^ ]+\\.rs:\\d+:\\d+"
    '';

    ".config/alacritty/theme.toml".text = with theme; ''
      # Source: https://github.com/alacritty/alacritty-theme/blob/master/themes/gruvbox_material_hard_dark.toml

      # Default colors
      [colors.primary]
      background = '${background}'
      foreground = '${foreground}'

      # Normal colors
      [colors.normal]
      black   = '${normal.black}'
      red     = '${normal.red}'
      green   = '${normal.green}'
      yellow  = '${normal.yellow}'
      blue    = '${normal.blue}'
      magenta = '${normal.magenta}'
      cyan    = '${normal.cyan}'
      white   = '${normal.white}'

      # Bright colors (same as normal colors)
      [colors.bright]
      black   = '${bright.black}'
      red     = '${bright.red}'
      green   = '${bright.green}'
      yellow  = '${bright.yellow}'
      blue    = '${bright.blue}'
      magenta = '${bright.magenta}'
      cyan    = '${bright.cyan}'
      white   = '${bright.white}'
'';
  };
}
