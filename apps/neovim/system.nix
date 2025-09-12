{ pkgs, lib, ... }:
let
  config = import ../../params.nix;
in {
  environment.systemPackages = with pkgs; [
    gcc     # Needed for the treesitter plugin, to be able to compile language parsers.
    ripgrep # Needed for the telescope plugin
  ];

  programs.neovim = {
    defaultEditor = true;
    enable = true;

    withPython3 = false;
    withRuby = false;

    configure = {
       # Vim configuration for root user only
      customRC = ''
        luafile /etc/xdg/nvim/init.lua
      '';
    };

    runtime = {
      "init.lua".text = import ./init.nix { pkgs = pkgs; };

      "ftplugin/python.lua".text = ''
        vim.o.expandtab = true
        vim.o.smartindent = true
        vim.o.textwidth = 79
        vim.o.colorcolumn = "73,+1"
      '';
      "ftplugin/nix.lua".text = ''
        vim.o.colorcolumn = "+0"
        vim.o.expandtab = true
        vim.o.shiftwidth = 2
        vim.o.tabstop = 2
        vim.o.textwidth = 100
      '';

      "lsp/bashls.lua".text = import ./lsp/bashls.nix { pkgs=pkgs; };
      "lsp/nixd.lua".text = import ./lsp/nixd.nix { pkgs=pkgs; };

      "lua/autocomplete.lua".text = builtins.readFile ./lua/autocomplete.lua;
      "lua/plugins.lua".text = import ./lua/plugins.nix { pkgs=pkgs; };
      "lua/lsp.lua".text = builtins.readFile ./lua/lsp.lua;

      "lua/snippets.lua".text = builtins.readFile ./lua/snippets.lua;
      "lua/snippets/python.lua".text = builtins.readFile ./lua/snippets/python.lua;

    # Some language servers are really not needed in a server environment, and some of them even
    # give an error when some system wide binaries are missing (e.g. ccls)
    } // lib.attrsets.optionalAttrs (config.environmentType == "desktop") {
      "lsp/ccls.lua".text = import ./lsp/ccls.nix { pkgs=pkgs; };
      "lsp/lua_ls.lua".text = import ./lsp/lua_ls.nix { pkgs=pkgs; };
      "lsp/postgres_lsp.lua".text = import ./lsp/postgres_lsp.nix { pkgs=pkgs; };
      "lsp/pylsp.lua".text = builtins.readFile ./lsp/pylsp.lua;
      "lsp/rust_analyzer.lua".text = import ./lsp/rust_analyzer.nix { pkgs=pkgs; };
      "lsp/vimls.lua".text = import ./lsp/vimls.nix { pkgs=pkgs; };
    };

    viAlias = true;
  };
}
