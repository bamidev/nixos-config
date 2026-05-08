{ lib, ... }:
let
  config = import ../../params.nix;
  pkgs = (import ../../sources.nix).editorPkgs.pkgs;
in {
  environment.systemPackages = with pkgs; [
    gcc     # Needed for the treesitter plugin, to be able to compile language parsers.
    nodejs_24
    ripgrep # Needed for the telescope plugin
    tree-sitter # Needed for nvim-treesitter

    # Install language servers globally so that the default LSP configurations may work within a
    # non-Nix environment as well. (Such as my VM's.)
    bash-language-server
    ltex-ls
    vscode-langservers-extracted
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
      "init.lua".source = ./init.lua;

      "ftplugin/python.lua".text = ''
        vim.bo.expandtab = true
        vim.bo.smartindent = true
        vim.wo.colorcolumn = '73,79'
        if vim.b.editorconfig then
          vim.wo.colorcolumn = '73,' .. (vim.b.editorconfig.max_line_length or '79')
        end
      '';
      "ftplugin/nix.lua".text = ''
        vim.wo.colorcolumn = '100'
        vim.bo.expandtab = true
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
      '';
      "ftplugin/rust.lua".source = ./ftplugin/rust.lua;
      "ftplugin/tex.lua".source = ./ftplugin/tex.lua;

      "lsp/bashls.lua".source = ./lsp/bashls.lua;
      "lsp/nixd.lua".text = import ./lsp/nixd.nix { pkgs=pkgs; };
      "lsp/vscode-json.lua".source = ./lsp/vscode-json.lua;
      "lsp/yamlls.lua".text = import ./lsp/yamlls.nix { pkgs=pkgs; };

      "lua/autocomplete.lua".source = ./lua/autocomplete.lua;
      "lua/commands.lua".source = ./lua/commands.lua;
      "lua/map.lua".source = ./lua/map.lua;
      "lua/plugins.lua".text = import ./lua/plugins.nix { pkgs=pkgs; };
      "lua/plugins/dap.lua".source = ./lua/plugins/dap.lua;
      "lua/plugins/dap-python.lua".source = ./lua/plugins/dap-python.lua;
      "lua/plugins/feline".source = ./lua/plugins/feline;
      "lua/plugins/feline.lua".source = ./lua/plugins/feline.lua;
      "lua/plugins/gitsigns.lua".source = ./lua/plugins/gitsigns.lua;
      "lua/plugins/indent-blankline.lua".source = ./lua/plugins/indent-blankline.lua;
      "lua/plugins/lua-snip.lua".text = import ./lua/plugins/lua-snip.nix { pkgs=pkgs; };
      "lua/plugins/ufo.lua".source = ./lua/plugins/ufo.lua;
      "lua/lsp.lua".text = import ./lua/lsp.nix { pkgs=pkgs; };
      "lua/pylsp.lua".source = ./lua/pylsp.lua;
      "lua/user-plugins.lua".source=  ./lua/user-plugins.lua;
      "lua/utils/git.lua".source = ./lua/utils/git.lua;

      "luasnippets".source = ./luasnippets;

    # Some language servers are really not needed in a server environment, and some of them even
    # give an error when some system wide binaries are missing (e.g. ccls)
    } // lib.attrsets.optionalAttrs (config.environmentType == "desktop") {
      "lsp/ccls.lua".text = import ./lsp/ccls.nix { pkgs=pkgs; };
      "lsp/csharp_ls.lua".text = import ./lsp/csharp_ls.nix { pkgs=pkgs; };
      "lsp/esbonio.lua".source = ./lsp/esbonio.lua;
      "lsp/gopls.lua".source = ./lsp/gopls.lua;
      "lsp/java_language_server.lua".text = import ./lsp/java_language_server.nix { pkgs=pkgs; };
      "lsp/lua_ls.lua".text = import ./lsp/lua_ls.nix { pkgs=pkgs; };
      "lsp/ltex.lua".source = ./lsp/ltex.lua;
      "lsp/markdown_oxide.lua".source = ./lsp/markdown_oxide.lua;
      "lsp/postgres_lsp.lua".text = import ./lsp/postgres_lsp.nix { pkgs=pkgs; };
      "lsp/pylsp.lua".source = ./lsp/pylsp.lua;
      "lsp/ruff.lua".text = import ./lsp/ruff.nix { pkgs=pkgs; };
      "lsp/rust_analyzer.lua".text = import ./lsp/rust_analyzer.nix { pkgs=pkgs; };
      "lsp/ts_ls.lua".text = import ./lsp/ts_ls.nix { pkgs=pkgs; };
      "lsp/vimls.lua".text = import ./lsp/vimls.nix { pkgs=pkgs; };
      "lsp/vscode-css.lua".source = ./lsp/vscode-css.lua;
      "lsp/vscode-eslint.lua".source = ./lsp/vscode-eslint.lua;
      "lsp/vscode-html.lua".source = ./lsp/vscode-html.lua;
    };

    viAlias = true;
  };
}
