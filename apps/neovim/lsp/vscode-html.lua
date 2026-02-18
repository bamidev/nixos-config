return {
	cmd = {'vscode-html-language-server', '--stdio'},
	filetypes = {'html'},
	on_attach = require('autocomplete'),
}
