{ pkgs, ... }:

let
  # Lua code to enable autocompletion
  lspCompletion = ''
    on_attach = function(client, bufnr)
      vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = true,
      })
      vim.keymap.set("i", "<C-space>", vim.lsp.completion.get, {
        desc = "Trigger autocompletion"
      })
    end,
  '';
in {
  programs.neovim = {
    defaultEditor = true;
    enable = true;

    withPython3 = false;
    withRuby = false;

    configure = {
       # Vim configuration for root user only
      customRC = ''
        lua << EOF
          ${import ./neovim/init.nix { pkgs = pkgs; }}
        EOF
      '';
    };

    runtime = {
      "ftplugin/c.lua" = {
        enable = true;
        text = ''
          vim.lsp.enable("ccls")
        '';
      };

      "ftplugin/cpp.lua" = {
        enable = true;
        text = ''
          vim.lsp.enable("ccls")
        '';
      };

      "ftplugin/lua.lua" = {
        enable = true;
        text = ''
          vim.lsp.start({
              cmd = {'${pkgs.lua-language-server}/bin/lua-language-server'},
              ${lspCompletion}
          })
        '';
      };

      "ftplugin/python.lua" = {
        enable = true;
        text = ''
          vim.o.expandtab = true
          vim.o.smartindent = true
          vim.o.textwidth = 79
          vim.o.colorcolumn = "73,+1"

          -- The language server
          vim.lsp.start({
            cmd = {'pylsp'},
            ${lspCompletion}
            settings = {
              pylsp = {
                configurationSources = {'flake8'},
                plugins = {
                  flake8 = {
                    enabled = true,
                  },
                  pydocstyle = {
                    enabled = true,
                  },
                  pyflakes = {
                    enabled = true,
                  },
                  pylint = {
                    enabled = true, 
                  },
                  rope_autoimport = {
                    enabled = true,
                  },
                  rope_completion = {
                    enabled = true,
                    eager = false,
                  }
                }
              }
            }
          })
        '';
      };

      "ftplugin/nix.lua" = {
        enable = true;
        text = ''
          vim.o.colorcolumn = "+0"
          vim.o.expandtab = true
          vim.o.shiftwidth = 2
          vim.o.tabstop = 2
          vim.o.textwidth = 100

          vim.lsp.start({
            cmd = {'${pkgs.nixd}/bin/nixd'},
            ${lspCompletion}
          })
        '';
      };

      "ftplugin/rust.lua" = {
        enable = true;
        text = ''
          vim.lsp.start({
            cmd = {'${pkgs.rust-analyzer}/bin/rust-analyzer'},
            ${lspCompletion}
          })
        '';
      };
      
      "ftplugin/sh.lua" = {
        enable = true;
        text = ''
          vim.lsp.start({
              cmd = { "${pkgs.bash-language-server}/bin/bash-language-server", "start" },
              ${lspCompletion}
          })
        '';
      };

      "ftplugin/sql.lua" = {
        enable = true;
        text = ''
          vim.lsp.start({
            cmd = { '${pkgs.postgres-lsp}/bin/postgrestools', 'lsp-proxy' },
            ${lspCompletion}
          })
        '';
      };

      "ftplugin/vim.lua" = {
        enable = true;
        text = ''
          vim.lsp.start({
            cmd = {'${pkgs.vim-language-server}/bin/vim-language-server'},
            ${lspCompletion}
          })
        '';
      };
    };

    viAlias = true;
  };
}
