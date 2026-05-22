vim.keymap.set({'n', 'v', 'x'}, ';', ':')
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)

vim.keymap.set('n', '<leader>fx', function()
	vim.lsp.buf.format({ async = true })
	print('Formatting...')
end)
