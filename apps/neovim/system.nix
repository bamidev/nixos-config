{ lib, inputs, params, ... }:
let
  pkgs = inputs.editorPkgs.legacyPackages.${builtins.currentSystem};
in {
  environment.systemPackages = with pkgs; [
    gcc     # Needed for the treesitter plugin, to be able to compile language parsers.
    nodejs_24
    ripgrep # Needed for the telescope plugin
    tree-sitter # Needed for nvim-treesitter

    # Install language servers globally so that the default LSP configurations may work within a
    # non-Nix environment as well. (Such as my VM's.)
    bash-language-server
  ] ++ (lib.optionals (params.environmentType == "desktop") (with pkgs; [
    basedpyright
    ltex-ls
    typescript-language-server
    vscode-langservers-extracted

    # pylsp with everything it needs, and debugpy
    (python3.withPackages (python-pkgs: with python-pkgs; [
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
    ]))
  ]));

  environment.etc."pylintrc".source = ./etc/pylintrc;

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;

    defaultEditor = true;
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;

    runtime = {
      "init.lua".text = import ./init.nix { lib=lib; pkgs=pkgs; };
    };

    viAlias = true;
  };

  system.activationScripts.neovimConfigRepo.text = ''
    function link() {
      if [ ! -e "/etc/xdg/nvim/$1" ]; then ln -s "/etc/xdg/extra-config/neovim/$1" "/etc/xdg/nvim/$1"; fi
    }

    link ftplugin
    link lsp
    link lua
    link luasnippets
  '';
}
