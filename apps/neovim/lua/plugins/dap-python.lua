local workspaceFolders = vim.lsp.buf.list_workspace_folders()
local workspaceFolder = vim.fn.getcwd()
if workspaceFolders[1] ~= nil then
	workspaceFolder = workspaceFolders[1]
end
local moduleFolder = nil
if workspaceFolder ~= nil then
	moduleFolder = vim.fs.dirname(workspaceFolder)
end
local module = vim.fs.basename(workspaceFolder)


return {
	"mfussenegger/nvim-dap-python",
	commit = "030385d03363988370adaa5cf21fa465daddb088",
	requires = "mfussenegger/nvim-dap",
	config = function()
		require("dap-python").setup("python")

		local dap = require("dap")
		local configurations = {}
		if module then
			configurations[1] = {
				type = "python";
				request = "launch";
				name = "Launch Python Module " .. module;
				module = "${workspaceFolderBasename}";
				cwd = moduleFolder;
				pythonPath = function()
					return "python"
				end
			}
		end
		vim.list_extend(configurations, {
			{
				type = "python";
				request = "launch";
				name = "Launch Python File";
				program = "python ${file}";
				pythonPath = function()
					return "python"
				end
			},
			{
				typ = "python";
				request = "launch";
				name = "Run with uv";
				program = "uv run";
				pythonPath = "python";
			},
		})

		dap.configurations.python = configurations
	end
}
