local python_path = vim.fs.abspath('~/lsp/venv/bin/python')
vim.lsp.config('esbonio', {
	cmd = {python_path, '-m', 'esbonio'},
	filetypes = {'rst'},
	root_markers = {'.git'},
})
