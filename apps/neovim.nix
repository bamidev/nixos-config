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
--local lspconfig = require('lspconfig')
--lspconfig.pyright.setup({})

vim.lsp.start({
	cmd = {'pylsp'},
	settings = {
		pylsp = {
			configurationSources = {'flake8'},
			plugins = {
				flake8 = {
					enabled = true,
        		},
				pyflakes = {
					enabled = true,
				},
				pylint = {
					enabled = true, 
				}
			}
		}
	}
})
--vim.lsp.start('pylsp')
--vim.api.nvim_command('LspStart')
'';
      };
    };

    viAlias = true;
    vimAlias = true;
  };
}
