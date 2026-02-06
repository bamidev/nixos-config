-- Neovim's own ftplugin for Rust overwrites my choice for expandtab
vim.g.rust_recommended_style = false
vim.wo.colorcolumn = '100'
vim.bo.expandtab = true

if vim.fn.filereadable('rustfmt.toml') == 1 then
	local fmt_file = io.open('rustfmt.toml', 'r')
	if fmt_file ~= nil then
		while (true) do
			local line = fmt_file:read()
			if line == nil then
				break
			end
			if string.find(line, 'hard_tabs%s=%strue') then
				vim.bo.expandtab = false
				break
			end
		end
		fmt_file:close()
	end
end
