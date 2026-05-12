vim.bo.expandtab = true
vim.bo.smartindent = true
vim.wo.colorcolumn = '73,79'
if vim.b.editorconfig then
  vim.wo.colorcolumn = '73,' .. (vim.b.editorconfig.max_line_length or '79')
end
