{ ... }: {
  home = {
    stateVersion = "25.05";

    file.".config/nvim/init.lua".text = ''
      vim.cmd('luafile /etc/xdg/nvim/init.lua')
    '';
  };
}
