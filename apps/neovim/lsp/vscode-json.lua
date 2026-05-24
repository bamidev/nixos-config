vim.lsp.config('vscode-json', {
	cmd = {'vscode-json-language-server', '--stdio'},
	filetypes = {'json'},
	init_options = {
	  provideFormatter = true,
	},
})
