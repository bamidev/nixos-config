{ lib, ... }:
let
  config = import ../../params.nix;
  pkgs = (import ../../sources.nix).nixpkgs25_05.pkgs;
in {
  environment.systemPackages = with pkgs; [
    gcc     # Needed for the treesitter plugin, to be able to compile language parsers.
    ripgrep # Needed for the telescope plugin
  ];

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

      "lsp/bashls.lua".text = import ./lsp/bashls.nix { pkgs=pkgs; };
      "lsp/nixd.lua".text = import ./lsp/nixd.nix { pkgs=pkgs; };
      "lsp/jsonls.lua".text = import ./lsp/jsonls.nix { pkgs=pkgs; };
      "lsp/yamlls.lua".text = import ./lsp/yamlls.nix { pkgs=pkgs; };

      "lua/autocomplete.lua".source = ./lua/autocomplete.lua;
      "lua/plugins.lua".text = import ./lua/plugins.nix { pkgs=pkgs; };
      "lua/plugins/dap.lua".source = ./lua/plugins/dap.lua;
      "lua/plugins/dap-python.lua".source = ./lua/plugins/dap-python.lua;
      "lua/plugins/feline".source = ./lua/plugins/feline;
      "lua/plugins/feline.lua".source = ./lua/plugins/feline.lua;
      "lua/plugins/gitsigns.lua".source = ./lua/plugins/gitsigns.lua;
      "lua/plugins/heirline".source = ./lua/plugins/heirline;
      "lua/plugins/heirline.lua".source = ./lua/plugins/heirline.lua;
      "lua/plugins/indent-blankline.lua".source = ./lua/plugins/indent-blankline.lua;
      "lua/plugins/lua-snip.lua".text = import ./lua/plugins/lua-snip.nix { pkgs=pkgs; };
      "lua/plugins/ufo.lua".source = ./lua/plugins/ufo.lua;
      "lua/lsp.lua".text = import ./lua/lsp.nix { pkgs=pkgs; };
      "lua/pylsp.lua".source = ./lua/pylsp.lua;
      "lua/utils/git.lua".source = ./lua/utils/git.lua;

      "luasnippets".source = ./luasnippets;

    # Some language servers are really not needed in a server environment, and some of them even
    # give an error when some system wide binaries are missing (e.g. ccls)
    } // lib.attrsets.optionalAttrs (config.environmentType == "desktop") {
      "lsp/ccls.lua".text = import ./lsp/ccls.nix { pkgs=pkgs; };
      "lsp/csharp_ls.lua".text = import ./lsp/csharp_ls.nix { pkgs=pkgs; };
      "lsp/esbonio.lua".source = ./lsp/esbonio.lua;
      "lsp/eslint.lua".text = import ./lsp/eslint.nix { pkgs=pkgs; };
      "lsp/gopls.lua".source = ./lsp/gopls.lua;
      "lsp/java_language_server.lua".text = import ./lsp/java_language_server.nix { pkgs=pkgs; };
      "lsp/lua_ls.lua".text = import ./lsp/lua_ls.nix { pkgs=pkgs; };
      "lsp/markdown_oxide.lua".text = import ./lsp/markdown_oxide.nix { pkgs=pkgs; };
      "lsp/postgres_lsp.lua".text = import ./lsp/postgres_lsp.nix { pkgs=pkgs; };
      "lsp/pylsp.lua".source = ./lsp/pylsp.lua;
      "lsp/ruff.lua".text = import ./lsp/ruff.nix { pkgs=pkgs; };
      "lsp/rust_analyzer.lua".text = import ./lsp/rust_analyzer.nix { pkgs=pkgs; };
      "lsp/ts_ls.lua".text = import ./lsp/ts_ls.nix { pkgs=pkgs; };
      "lsp/vimls.lua".text = import ./lsp/vimls.nix { pkgs=pkgs; };
      "lsp/vscode-css.lua".text = import ./lsp/vscode-css.nix { pkgs=pkgs; };
      "lsp/vscode-html.lua".text = import ./lsp/vscode-html.nix { pkgs=pkgs; };
      "lsp/vscode-markdown.lua".text = import ./lsp/vscode-markdown.nix { pkgs=pkgs; };
    };

    viAlias = true;
  };
}
