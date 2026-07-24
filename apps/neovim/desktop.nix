{
  config,
  lib,
  inputs,
  ...
}:
let
  pkgs = inputs.editorPkgs.legacyPackages.${builtins.currentSystem};
  newPkgs = inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
in
{
  # TODO: Decide if it is better to install these packages system-wide, rather than with home-manager
  # All the language servers that are available on machine's used for development.
  home.packages =
    with pkgs;
    [
      basedpyright
      docker-compose-language-service
      #docker-language-server
      ltex-ls
      lua-language-server
      vim-language-server

      # pylsp with everything it needs, and debugpy
      (python3.withPackages (
        python-pkgs: with python-pkgs; [
          black
          debugpy
          flake8
          jedi
          mccabe
          pydocstyle
          pylint
          pyls-isort
          pyls-memestra
          pylsp-mypy
          python-lsp-server
          rope
        ]
      ))
    ]
    ++ [
      newPkgs.docker-language-server
    ];

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
