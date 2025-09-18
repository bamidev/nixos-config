{ pkgs, lib, ... }:
let
  config = import ../../params.nix;
  pinnedPkgs = (import ../../pins.nix).nixpkgs25_05.pkgs;
in {
  environment.systemPackages = with pinnedPkgs; [
    gcc     # Needed for the treesitter plugin, to be able to compile language parsers.
    ripgrep # Needed for the telescope plugin
  ];

  programs.neovim = {
    enable = true;
    package = pinnedPkgs.neovim-unwrapped;

    defaultEditor = true;
    withNodeJs = false;
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
        vim.opt.expandtab = true
        vim.opt.smartindent = true
        vim.opt.textwidth = tonumber(vim.b.editorconfig.max_line_length) or 79
        vim.opt.colorcolumn = "73,+1"
      '';
      "ftplugin/nix.lua".text = ''
        vim.opt.colorcolumn = "+0"
        vim.opt.expandtab = true
        vim.opt.shiftwidth = 2
        vim.opt.tabstop = 2
        vim.opt.textwidth = 100
      '';

      "lsp/bashls.lua".text = import ./lsp/bashls.nix { pkgs=pkgs; };
      "lsp/nixd.lua".text = import ./lsp/nixd.nix { pkgs=pkgs; };

      "lua/autocomplete.lua".source = ./lua/autocomplete.lua;
      "lua/plugins.lua".text = import ./lua/plugins.nix { pkgs=pkgs; };
      "lua/lsp.lua".text = import ./lua/lsp.nix { pkgs=pkgs; };

      "luasnippets".source = ./luasnippets;

    # Some language servers are really not needed in a server environment, and some of them even
    # give an error when some system wide binaries are missing (e.g. ccls)
    } // lib.attrsets.optionalAttrs (config.environmentType == "desktop") {
      "lsp/ccls.lua".text = import ./lsp/ccls.nix { pkgs=pkgs; };
      "lsp/esbonio.lua".source = ./lsp/esbonio.lua;
      "lsp/lua_ls.lua".text = import ./lsp/lua_ls.nix { pkgs=pkgs; };
      "lsp/markdown_oxide.lua".text = import ./lsp/markdown_oxide.nix { pkgs=pkgs; };
      "lsp/postgres_lsp.lua".text = import ./lsp/postgres_lsp.nix { pkgs=pkgs; };
      "lsp/pylsp.lua".source = ./lsp/pylsp.lua;
      "lsp/rust_analyzer.lua".text = import ./lsp/rust_analyzer.nix { pkgs=pkgs; };
      "lsp/vimls.lua".text = import ./lsp/vimls.nix { pkgs=pkgs; };
    };

    viAlias = true;
  };
}
