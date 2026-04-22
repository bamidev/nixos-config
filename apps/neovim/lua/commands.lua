vim.api.nvim_create_user_command('Wordcount', function()
	print('Words: ' .. vim.fn.wordcount().words)
end, {
	desc = 'Show word count of the document.',
})
