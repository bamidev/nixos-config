vim.lsp.config('vscode-json', {
	cmd = {'vscode-json-language-server', '--stdio'},
	filetypes = {'json'},
	on_attach = require('autocomplete'),
	init_options = {
	  provideFormatter = true,
	},
})
