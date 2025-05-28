{ pkgs, ... }:

{
  programs.neovim = {
    defaultEditor = true;
    enable = true;

    configure = {
       # Vim configuration for root user only
      customRC = ''
luafile ${./neovim/init.lua}
'';
    };

    runtime = {
      "ftplugin/python.lua" = {
        enable = true;
        text = ''
vim.o.expandtab = true
vim.o.textwidth = 79
vim.o.colorcolumn = "73,+1"
vim.o.foldmethod = "indent"
vim.o.foldlevel = 1
vim.o.foldnestmax = 2


-- The language server
local lspconfig = require('lspconfig')
lspconfig.pyright.setup({})
vim.api.nvim_command('LspStart')
'';
      };
    };

    viAlias = true;
    vimAlias = true;
  };
}
