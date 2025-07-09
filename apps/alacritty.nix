{
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

    ".config/alacritty/theme.toml".text = ''
      # Source: https://github.com/alacritty/alacritty-theme/blob/master/themes/gruvbox_material_hard_dark.toml

      # Default colors
      [colors.primary]
      background = '#141617'
      foreground = '#e2cca9'

      # Normal colors
      [colors.normal]
      black   = '#32302f'
      red     = '#db4740'
      green   = '#b0b846'
      yellow  = '#e9b143'
      blue    = '#80aa9e'
      magenta = '#d3869b'
      cyan    = '#8bba7f'
      white   = '#a89984'

      # Bright colors (same as normal colors)
      [colors.bright]
      black   = '#32302f'
      red     = '#f2584b'
      green   = '#b0b846'
      yellow  = '#e9b143'
      blue    = '#80aa9e'
      magenta = '#d3869b'
      cyan    = '#8bba7f'
      white   = '#e2cca9'
'';
  };
}
