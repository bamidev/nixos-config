{ pkgs, ... }:

{
  programs.neovim = {
    defaultEditor = true;
    enable = true;

    withPython3 = false;

    configure = {
       # Vim configuration for root user only
      customRC = ''
        luafile ${./neovim/init.lua}
      '';
    };

    runtime = {
      "ftplugin/bash.lua" = {
        enable = true;
        text = ''
          vim.lsp.start({
              cmd = { "${pkgs.bash-language-server}/bin/bash-language-server", "start" },
          })
        '';
      };

      "ftplugin/c.lua" = {
        enable = true;
        text = ''
          vim.lsp.start({
              cmd = {'${pkgs.ccls}/bin/ccls'},
          })
        '';
      };

      "ftplugin/lua.lua" = {
        enable = true;
        text = ''
          vim.lsp.start({
              cmd = {'${pkgs.lua-language-server}/bin/lua-language-server'},
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
          vim.o.foldmethod = "indent"
          vim.o.foldlevel = 1
          vim.o.foldnestmax = 2


          -- The language server
          vim.lsp.start({
            cmd = {'pylsp'},
            on_attach = function(client, bufnr)
              -- Enable autocompletion suggestions
              vim.lsp.completion.enable(true, client.id, bufnr, {
                convert = function(item)
                  return { abbr = item.label:gsub("%b()", "") }
                end,
              })
            end,
            autocomplete = true,
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
                    eager = true,
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
          })
        '';
      };

      "ftplugin/rust.lua" = {
        enable = true;
        text = ''
          vim.lsp.start({
              cmd = {'${pkgs.rust-analyzer}/bin/rust-analyzer'},
          })
        '';
      };
      
      "ftplugin/sh.lua" = {
        enable = true;
        text = ''
          --local folderOfThisFile = (...):match("(.-)[^%.]+$")
          --require('./bash')

          lines = vim.api.nvim_buf_get_lines(0, 0, 1, false)
          if #lines > 0 then
              local first_line = lines[0]
              io.stdout:write(first_line)
              if first_line == '#!/bin/bash' or first_line == '#!/usr/bin/bash' or first_line == '#!/usr/bin/env bash' then
                vim.lsp.start({
                    cmd = {'${pkgs.bash-language-server}/bin/bbash-language-server'},
                })
              end
          end
        '';
      };

      "ftplugin/sql.lua" = {
        enable = true;
        text = ''
          vim.lsp.start({
              cmd = { '${pkgs.postgres-lsp}/bin/postgrestools', 'lsp-proxy' },
          })
        '';
      };

      "ftplugin/vim.lua" = {
        enable = true;
        text = ''
          vim.lsp.start({
              cmd = {'${pkgs.vim-language-server}/bin/vim-language-server'},
          })
        '';
      };
    };

    viAlias = true;
    vimAlias = true;
  };
}
