{ pkgs, ... }: ''
  local lsp_dir = vim.fs.abspath('~/lsp')

  -- A virtual environment to install servers via pip
  local venv_dir = lsp_dir .. '/venv'
  if vim.fn.isdirectory(venv_dir) == 0 then
    os.execute('${pkgs.python314}/bin/python -m venv ' .. venv_dir)
    os.execute(venv_dir .. '/bin/pip install -r ' .. lsp_dir .. '/requirements.txt')
  end

  local odoo_dir = lsp_dir .. '/odoo'
  local odools_dir = odoo_dir .. '/odoo-ls'
  if vim.fn.isdirectory(odoo_dir) == 0 then
    for i = 8, 19, 1 do
      os.execute('git clone -b ' .. i .. '.0 --depth=1 https://github.com/odoo/odoo.git ' .. odoo_dir .. '/' .. i .. '.0')
    end

    os.execute('git clone -b "1.0.1" --recurse-submodules --depth=1 https://github.com/odoo/odoo-ls.git ' .. odools_dir)
    os.execute('${pkgs.rustup}/bin/rustup install 1.90.0')
    os.execute('cd "' .. odools_dir .. '/server" && ${pkgs.rustup}/bin/rustup run 1.90.0 cargo  build --release')
    os.execute('cp ' .. odools_dir .. '/server/target/release/odoo_ls_server ' .. odools_dir .. '/server/odoo_ls_server')
  end


  vim.lsp.enable('bashls')
  vim.lsp.enable('ccls')
  vim.lsp.enable('esbonio')
  vim.lsp.enable('lua_ls')
  vim.lsp.enable('markdown_oxide')
  vim.lsp.enable('nixd')
  vim.lsp.enable('odools')
  vim.lsp.enable('postgres_lsp')
  vim.lsp.enable('pylsp')
  vim.lsp.enable('rust_analyzer')
  vim.lsp.enable('vimls')
''
