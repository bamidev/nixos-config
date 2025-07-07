{ pkgs, ... }:
{
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
      "init.lua".text = import ./neovim/init.nix { pkgs = pkgs; };

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

      "lsp/bashls.lua".text = import ./neovim/lsp/bashls.nix { pkgs=pkgs; };
      "lsp/ccls.lua".text = import ./neovim/lsp/ccls.nix { pkgs=pkgs; };
      "lsp/lua_ls.lua".text = import ./neovim/lsp/lua_ls.nix { pkgs=pkgs; };
      "lsp/nixd.lua".text = import ./neovim/lsp/nixd.nix { pkgs=pkgs; };
      "lsp/postgres_lsp.lua".text = import ./neovim/lsp/postgres_lsp.nix { pkgs=pkgs; };
      "lsp/pylsp.lua".text = builtins.readFile ./neovim/lsp/pylsp.lua;
      "lsp/rust_analyzer.lua".text = import ./neovim/lsp/rust_analyzer.nix { pkgs=pkgs; };
      "lsp/vimls.lua".text = import ./neovim/lsp/vimls.nix { pkgs=pkgs; };

      "lua/autocomplete.lua".text = builtins.readFile ./neovim/lua/autocomplete.lua;
      "lua/plugins.lua".text = builtins.readFile ./neovim/lua/plugins.lua;
      "lua/lsp.lua".text = builtins.readFile ./neovim/lua/lsp.lua;
    };

    viAlias = true;
  };
}
