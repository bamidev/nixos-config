{ pkgs, ... }: ''
  local lsp_dir = vim.fs.abspath('~/lsp')

  -- A virtual environment to install servers via pip
  local venv_dir = lsp_dir .. '/venv'
  if vim.fn.isdirectory(venv_dir) == 0 then
    os.execute('${pkgs.python314}/bin/python -m venv ' .. venv_dir)
    os.execute(venv_dir .. '/bin/pip install -r ' .. lsp_dir .. '/requirements.txt')
  end


  -- Enable sweet inlay hints where available
  vim.keymap.set('n', '<C-h>', function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  end)


  vim.lsp.enable('bashls')
  vim.lsp.enable('ccls')
  vim.lsp.enable('csharp_ls')
  vim.lsp.enable('esbonio')
  vim.lsp.enable('eslint')
  vim.lsp.enable('gopls')
  vim.lsp.enable('java_language_server')
  vim.lsp.enable('ltex')
  vim.lsp.enable('lua_ls')
  vim.lsp.enable('markdown_oxide')
  vim.lsp.enable('nixd')
  vim.lsp.enable('postgres_lsp')
  vim.lsp.enable('pylsp')
  vim.lsp.enable('rust_analyzer')
  vim.lsp.enable('ts_ls')
  vim.lsp.enable('vimls')
  vim.lsp.enable('vscode-css')
  vim.lsp.enable('vscode-html')
  vim.lsp.enable('vscode-json')
  vim.lsp.enable('vscode-markdown')
  vim.lsp.enable('yamlls')
''
