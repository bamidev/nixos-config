vim.lsp.config('ts_ls', {
	cmd = {'typescript-language-server', '--stdio'},
	on_attach = require('autocomplete'),
})
