return {
	"mfussenegger/nvim-dap-python",
	commit = "030385d03363988370adaa5cf21fa465daddb088",
	requires = "mfussenegger/nvim-dap",
	config = function()
		require("dap-python").setup("python")

		local dap = require("dap")
		dap.configurations.python = {
			{
				type = "python";
				request = "launch";
				name = "Launch Odoo from within Waft";
				program = "''${workspaceFolder}/custom/src/odoo/odoo-bin";
				pythonPath = function()
					return "''${workspaceFolder}/.venv/bin/python"
				end
			},
			{
				type = "python";
				request = "launch";
				name = "Launch Odoo from within Wax";
				program = "''${workspaceFolder}/wax/repos/odoo/odoo-bin";
				pythonPath = function()
					return "''${workspaceFolder}/wax/venv/bin/python"
				end
			},
			{
				type = "python";
				request = "launch";
				name = "Launch Python File";
				program = "''${file}";
				pythonPath = function()
					return "python"
				end
			},
		}
	end
}
