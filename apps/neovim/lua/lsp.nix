{ pkgs, ... }: ''
	local lsp_dir = vim.fs.abspath('~/lsp')
	local venv_dir = lsp_dir .. '/venv'
	if vim.fn.isdirectory(venv_dir) == 0 then
		os.execute('${pkgs.python314}/bin/python -m venv ' .. venv_dir)
		os.execute(venv_dir .. '/bin/pip install -r ' .. lsp_dir .. '/requirements.txt')
	end


	vim.lsp.enable('bashls')
	vim.lsp.enable('ccls')
	vim.lsp.enable('esbonio')
	vim.lsp.enable('lua_ls')
	vim.lsp.enable('markdown_oxide')
	vim.lsp.enable('nixd')
	vim.lsp.enable('postgres_lsp')
	vim.lsp.enable('pylsp')
	vim.lsp.enable('rust_analyzer')
	vim.lsp.enable('vimls')
''
