vim.opt.textwidth = 88
if vim.b.editorconfig then
	vim.opt.textwidth = tonumber(vim.b.editorconfig.max_line_length) or vim.opt.textwidth
end
