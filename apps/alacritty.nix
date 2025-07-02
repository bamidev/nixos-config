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
      background = '#1d2021'
      foreground = '#d4be98'

      # Normal colors
      [colors.normal]
      black   = '#32302f'
      red     = '#ea6962'
      green   = '#a9b665'
      yellow  = '#d8a657'
      blue    = '#7daea3'
      magenta = '#d3869b'
      cyan    = '#89b482'
      white   = '#d4be98'

      # Bright colors (same as normal colors)
      [colors.bright]
      black   = '#32302f'
      red     = '#ea6962'
      green   = '#a9b665'
      yellow  = '#d8a657'
      blue    = '#7daea3'
      magenta = '#d3869b'
      cyan    = '#89b482'
      white   = '#d4be98'
'';
  };
}
