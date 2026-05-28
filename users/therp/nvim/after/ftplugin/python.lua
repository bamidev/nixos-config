vim.opt.colorcolumn = '73,88'
if vim.b.editorconfig then
	vim.opt.colorcolumn = '73,' .. (vim.b.editorconfig.max_line_length or '88')
end

vim.list_extend(
	require('dap').configurations.python,
	{
		{
			type = "python";
			request = "launch";
			name = "Launch Odoo from within Wax";
			program = "${workspaceFolder}/wax/repos/odoo/odoo-bin";
			pythonPath = function()
				return "${workspaceFolder}/wax/venv/bin/python"
			end
		},
		{
			type = "python";
			request = "launch";
			name = "Launch Odoo from within Waft";
			program = "${workspaceFolder}/custom/src/odoo/odoo-bin";
			pythonPath = function()
				return "''${workspaceFolder}/.venv/bin/python"
			end
		},
	}
)
