local python_path = vim.fs.abspath('~/lsp/venv/bin/python')
vim.lsp.config('esbonio', {
	cmd = {python_path, '-m', 'esbonio'},
	filetypes = {'rst'},
	on_attach = require('autocomplete'),
	root_markers = {'.git'},
})
