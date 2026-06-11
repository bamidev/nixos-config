{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.file.".local/share/applications/neovim.desktop".text = ''
    [Desktop Entry]
    Name=Neovim
    GenericName=Text Editor
    Comment=Edit text files
    Exec=${lib.getExe pkgs.alacritty} -e ${lib.getExe config.programs.neovim.package} %F
    Type=Application
    Keywords=Text;editor;
    Icon=nvim
    Categories=Utility;TextEditor;
    MimeType=text/*;
  '';
}
