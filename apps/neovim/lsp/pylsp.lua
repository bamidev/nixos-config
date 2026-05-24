vim.lsp.config('pylsp', {
	cmd = {'pylsp'},
	filetypes = {'python'},
	settings = require('pylsp').settings,
	root_markers = {'requirements.txt', '.git'},
	capabilities = require('lsp.capabilities')
})
