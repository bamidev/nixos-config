{ pkgs, ... }:

#let
#  myConfig = pkgs.vimUtils.buildVimPlugin {
#    name = "my-config";
#    src = "${./neovim/init.lua}";
#  };
#in {
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
      "nvim.lua" = {
        enable = true;
	text = ''
vim.o.number = true
vim.o.smartident = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.termguicolors = true
'';
      };
      "ftplugin/python.lua" = {
        enable = true;
        text = ''
vim.o.expandtab = true
vim.o.textwidth = 79
vim.o.colorcolumn = "73,+1"
vim.o.foldmethod = "indent"
vim.o.foldlevel = 1
vim.o.foldnestmax = 2

vim.lsp.start_client({
  name = 'my-ls',
  cmd = {'python-language-server'},
  root_dir = vim.fs.dirname(vim.fs.find({'pyproject.toml', 'setup.py'}, { upward = true })[1]),
})
'';
      };
    };

    viAlias = true;
    vimAlias = true;
  };
}
