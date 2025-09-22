{ pkgs, lib, ... }:
let
  params = import ./odoo-params.nix;
in ''
  local lsp_dir = vim.fs.abspath('~/lsp')
  local odoo_dir = lsp_dir .. '/odoo'

  for i = ${toString params.lspVersions.start}, ${toString params.lspVersions.stop}, 1 do
    local version_dir = odoo_dir .. '/' .. i .. '.0'
    local odoo_repo_dir = version_dir .. '/odoo'
    local enterprise_repo_dir = version_dir .. '/enterprise'

    if vim.fn.isdirectory(odoo_repo_dir) == 0 then
      os.execute('git clone -b ' .. i .. '.0 --depth=1 ${params.lspOdooRepoUrl} "' .. odoo_repo_dir .. '"')
    end
    if vim.fn.isdirectory(enterprise_repo_dir) == 0 then
      os.execute('git clone -b ' .. i .. '.0 --depth=1 ${params.lspEnterpriseRepoUrl} "' .. enterprise_repo_dir .. '"')
    end

    local repos = {${lib.strings.concatStrings (lib.lists.forEach params.lspOcaRepos (repo: "\"${repo}\", "))}}
    for _, repo in pairs(repos) do
      local oca_repo_dir = version_dir .. '/' .. repo
      if vim.fn.isdirectory(oca_repo_dir) == 0 then
        -- Precreate the repo directory, so that when the command fails, the cloning is not tried
        -- again.
        os.execute('mkdir "' .. oca_repo_dir .. '"')
        os.execute('git clone -b ' .. i .. '.0 --depth=1 https://github.com/OCA/' .. repo .. '.git "' .. oca_repo_dir .. '"')
      end
    end
  end

  local odools_dir = odoo_dir .. '/odoo-ls'
  if vim.fn.isdirectory(odools_dir) == 0 then
    os.execute('git clone -b "1.0.1" --recurse-submodules --depth=1 https://github.com/odoo/odoo-ls.git ' .. odools_dir)
    os.execute('${pkgs.rustup}/bin/rustup install 1.90.0')
    os.execute('cd "' .. odools_dir .. '/server" && ${pkgs.rustup}/bin/rustup run 1.90.0 cargo  build --release')
    os.execute('cp "' .. odools_dir .. '/server/target/release/odoo_ls_server" "' .. odools_dir .. '/server/odoo_ls_server"')
  end


  vim.lsp.enable('odools')
''
