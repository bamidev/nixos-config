{ ... }:
{
  home.file.".local/share/applications/neovim.desktop".text = ''
    [Desktop Entry]
    Name=Neovim
    GenericName=Text Editor
    Comment=Edit text files
    TryExec=nvim
    Exec=$TERMINAL -e nvim %F
    Type=Application
    Keywords=Text;editor;
    Icon=nvim
    Categories=Utility;TextEditor;
    MimeType=text/*;
  '';
}
