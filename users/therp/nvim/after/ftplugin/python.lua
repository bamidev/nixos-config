vim.opt.colorcolumn = '73,88'
if vim.b.editorconfig then
	vim.opt.colorcolumn = '73,' .. (vim.b.editorconfig.max_line_length or '88')
end


