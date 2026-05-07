vim.lsp.config('ltex', {
	cmd = {'ltex-ls'},
	autocomplete = require('autocomplete'),
	settings = {
		ltex = {
			language = "auto",
		},
	},
})
