return function(client, bufnr)
	vim.lsp.completion.enable(true, client.id, bufnr, {
		autotrigger = true,
	})
	vim.keymap.set("i", "<C-space>", vim.lsp.completion.get, {
		desc = "Trigger autocompletion"
	})
end
