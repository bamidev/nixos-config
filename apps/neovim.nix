{ ... }:

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
              cmd = { "bash-language-server", "start" },
	      })
		  '';
	  };

      "ftplugin/lua.lua" = {
        enable = true;
	    text = ''
	      vim.lsp.start({
              cmd = {'lua-language-server'},
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
'';
      };

      "ftplugin/nix.lua" = {
        enable = true;
        text = ''
          vim.o.expandtab = true

          vim.lsp.start({
              cmd = {'nixd'},
          })
        '';
      };
      
      "ftplugin/sh.lua" = {
        enable = true;
	    text = ''
          --local folderOfThisFile = (...):match("(.-)[^%.]+$")
	      --require('./bash')
	      vim.lsp.start({
              cmd = {'bash-language-server'},
	      })
		'';
	  };

      "ftplugin/sql.lua" = {
        enable = true;
        text = ''
          vim.lsp.start({
              cmd = { "postgrestools", "lsp-proxy" },
          })
        '';
      };

      "ftplugin/vim.lua" = {
        enable = true;
        text = ''
          vim.lsp.start({
              cmd = {'vim-language-server'},
          })
        '';
      };
    };

    viAlias = true;
    vimAlias = true;
  };
}
