vim.keymap.set({'n', 'v', 'x'}, ';', ':')
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)

vim.keymap.set('n', '<C-h>', function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)
vim.keymap.set('n', '<leader>fx', function()
	vim.lsp.buf.format({ async = true })
	print('Formatting...')
end)


vim.keymap.set("i", "<C-space>", vim.lsp.completion.get, {
	desc = "Trigger autocompletion"
})
