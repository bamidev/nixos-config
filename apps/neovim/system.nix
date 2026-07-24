{
  lib,
  inputs,
  ...
}:
let
  pkgs = inputs.editorPkgs.legacyPackages.${builtins.currentSystem};
in
{
  environment.systemPackages = with pkgs; [
    gcc # Needed for the treesitter plugin, to be able to compile language parsers.
    nodejs_24
    ripgrep # Needed for the telescope plugin
    tree-sitter # Needed for nvim-treesitter

    # Install language servers globally so that the default LSP configurations may work within a
    # non-Nix environment as well. (Such as my VM's.)
    bash-language-server
    nixd
    systemd-language-server
    vscode-json-languageserver
    yaml-language-server
  ];

  environment.etc."pylintrc".source = ./etc/pylintrc;

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;

    runtime = {
      "init.lua".text = import ./init.nix {
        lib = lib;
        pkgs = pkgs;
      };
    };

    viAlias = true;
  };

  system.activationScripts.neovimConfigRepo.text = ''
    function link() {
      if [ ! -h "/etc/xdg/nvim/$1" ]; then ln -s "/etc/xdg/extra-config/neovim/$1" "/etc/xdg/nvim/$1"; fi
    }

    link ftplugin
    link lsp
    link lua
    link luasnippets
  '';
}
