{ pkgs, ... }:
let
  version = "1.2.0";
  rust_version = "1.91.0";
in ''
  local lsp_dir = vim.fs.abspath('~/lsp')

  local odools_dir = lsp_dir .. '/odoo-ls'
  if vim.fn.isdirectory(odools_dir) == 0 then
    os.execute('git clone -b "${version}" --recurse-submodules --depth=1 https://github.com/odoo/odoo-ls.git ' .. odools_dir)
    local rustup_bin = 'rustup'
    if vim.fn.filereadable('${pkgs.rustup}/bin/rustup') == 1 then
      rustup_bin = '${pkgs.rustup}/bin/rustup'
    end
    os.execute(rustup_bin .. ' install ${rust_version}')
    os.execute('cd "' .. odools_dir .. '/server" && ' .. rustup_bin .. ' run ${rust_version} cargo build --release')
    os.execute('cp "' .. odools_dir .. '/server/target/release/odoo_ls_server" "' .. odools_dir .. '/server/odoo_ls_server"')

    os.execute('sleep 10')
  end
''
