{ pkgs, ... }:
let
  params = import ./odoo-params.nix;
in ''
  local lsp_dir = vim.fs.abspath('~/lsp')
  local odoo_dir = lsp_dir .. '/odoo'

  for i = ${toString params.lspVersions.start}, ${toString params.lspVersions.stop}, 1 do
    local version_dir = odoo_dir .. '/' .. i .. '.0'
    local wax_dir = version_dir .. '/wax'

    if vim.fn.isdirectory(wax_dir) == 0 then
      os.execute('${pkgs.coreutils}/bin/cp "' .. version_dir .. '/flake.nix.example" "' .. version_dir .. '/flake.nix"')
      os.execute('cd "' .. version_dir .. '" && nix develop --command build')
    fi

  local odools_dir = odoo_dir .. '/odoo-ls'
  if vim.fn.isdirectory(odools_dir) == 0 then
    os.execute('git clone -b "1.0.2" --recurse-submodules --depth=1 https://github.com/odoo/odoo-ls.git ' .. odools_dir)
    os.execute('${pkgs.rustup}/bin/rustup install 1.90.0')
    os.execute('cd "' .. odools_dir .. '/server" && ${pkgs.rustup}/bin/rustup run 1.90.0 cargo  build --release')
    os.execute('cp "' .. odools_dir .. '/server/target/release/odoo_ls_server" "' .. odools_dir .. '/server/odoo_ls_server"')
  end

  --os.execute('sleep 5')
  vim.lsp.enable('odools')
''
