return {
	"rcarriga/nvim-dap-ui",
	tag = "v4.0.0",
	requires = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		local dapui = require("dapui")
		dapui.setup({
			layouts = {
				{
					elements = {
						{ size = 0.25, id = "breakpoints" },
						{ size = 0.25, id = "watches" },
						{ size = 0.25, id = "stacks" },
						{ size = 0.25, id = "scopes" },
					},
					position = "right",
					size = 40,
				},
				{
					elements = {
						--{ size = 0.25, id = "console" },
						{ size = 0.75, id = "repl" },
					},
					position = "bottom",
					size = 10,
				},
			},
		})

		vim.keymap.set('n', '<F12>', dapui.toggle)
	end
}
