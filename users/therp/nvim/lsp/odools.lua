local lsp_dir = vim.fs.abspath('~/lsp/odoo')

local server_dir = lsp_dir .. '/odoo-ls/server'


local function check_git_branch()
	local c = io.popen("git rev-parse --abbrev-ref HEAD")
	if c == nil then
		return nil
	end

	local output = c:read("*l")
	c:close()
	return output
end

local function find_odoo_version_in_branch_name(branch)
	local _, endIndex = string.find(branch, "-", 1, true)
	local versionString = string.sub(branch, 1, endIndex - 1)
	local result, _ = string.find(versionString, ".", 2, true)
	if result == nil then
		return nil
	end
	return versionString
end

local function find_odoo_version()
	local branch = check_git_branch()
	if branch == nil then return nil end
	return find_odoo_version_in_branch_name(branch)
end


local branch = check_git_branch()
local odoo_version = nil
if branch ~= nil then odoo_version = find_odoo_version_in_branch_name(branch) end
local odoo_profile = nil
if odoo_version ~= nil then odoo_profile = 'setup-' .. odoo_version end


return {
	cmd = {
		server_dir .. '/odoo_ls_server',
	},
	filetypes = { 'python' },
	on_attach = function(client, _)
		vim.api.nvim_create_user_command('OdooProfile', function(e)
			local profile_name = e.args
			client.notify("workspace/didChangeConfiguration", {
				settings = {
					Odoo = {
						selectedProfile = profile_name
					}
				}
			})
		end, {
			desc = "Switch the profile used by the Odoo language server.",
			nargs = 1,
		})

		return require('autocomplete')
	end,
	root_markers = {'.git'},
	settings = {
		Odoo = {
			selectedProfile = odoo_profile
		},
	},
}
