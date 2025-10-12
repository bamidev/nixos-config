return {
	"mfussenegger/nvim-dap",
	tag = "0.10.0",
	config = function()
		local dap = require("dap")
		vim.keymap.set('n', '<F1>', dap.continue)
		vim.keymap.set('n', '<F2>', dap.step_over)
		vim.keymap.set('n', '<F3>', dap.step_into)
		vim.keymap.set('n', '<F7>', dap.toggle_breakpoint)
		vim.keymap.set('n', '<F11>', dap.repl.open)
	end
}
