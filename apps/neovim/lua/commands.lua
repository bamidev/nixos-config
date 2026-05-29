vim.api.nvim_create_user_command('Wordcount', function()
	print('Words: ' .. vim.fn.wordcount().words)
end, {
	desc = 'Show word count of the document.',
})

vim.api.nvim_create_user_command('Sort', function()
	vim.lsp.buf.code_action({
		context = { only = { "source.organizeImports" } },
		apply = true,
	})
end, {
	desc = 'Sort the import block.',
})
