{ pkgs, ... }:
let
  version = "1.3.2";
  rust_version = "1.94.0";
in ''
  local lsp_dir = vim.fs.abspath('~/lsp')
  local odools_dir = lsp_dir .. '/odoo-ls'
  local odools_binary_source = odools_dir .. '/server/target/release/odoo_ls_server'
  local odools_binary_target = odools_dir .. '/server/odoo_ls_server'
  
  if vim.fn.filereadable(odools_binary_target) == 0 then
    if vim.fn.isdirectory(odools_dir) == 0 then
      os.execute('git clone -b "${version}" --recurse-submodules --depth=1 https://github.com/odoo/odoo-ls.git ' .. odools_dir)
    end
    if vim.fn.filereadable(odools_binary_source) == 0 then
      os.execute('rustup install ${rust_version}')
      os.execute('cd "' .. odools_dir .. '/server" && rustup run ${rust_version} cargo build --release')
      os.execute('cp "' .. odools_binary_source .. '" "' .. odools_binary_target .. '"')
    end

    os.execute('sleep 10')
  end

  local server_dir = odools_dir .. '/server'
  local odoo_version = require('utils.odoo').get_odoo_version()
  local odoo_profile = nil
  if odoo_version ~= nil then odoo_profile = 'setup-' .. odoo_version .. '.0' end
''
