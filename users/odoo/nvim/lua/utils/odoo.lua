local this = {}
local git = require('utils.git')


local function check_pip_odoo_version_output()
	if vim.b.pip_odoo_version_output ~= nil then
		return vim.b.pip_odoo_version_output
	end

	local c = io.popen("pip show odoo | grep Version:")
	if c == nil then
		vim.b.pip_odoo_version_output = ""
		return ""
	end

	local output = c:read("*l")
	c:close()
	vim.b.pip_odoo_version_output = output or ""
	return output
end

local function find_odoo_version_in_branch_name(branch)
	local _, endIndex = string.find(branch, "-", 1, true)
	if endIndex == nil then
		endIndex = #branch
	else
		endIndex = endIndex - 1
	end
	local versionString = string.sub(branch, 1, endIndex)
	local result, _ = string.find(versionString, ".", 1, true)
	if result == nil then
		return nil
	end
	return versionString, endIndex
end

local function find_odoo_version_in_pip_output(output)
	local _, endIndex = string.find(output, "Version: ", 1, true)
	if endIndex == nil then
		return nil
	end
	local versionString = string.sub(output, endIndex + 1)
	local result, _ = string.find(versionString, ".", 1, true)
	if result == nil then
		return nil
	end
	return versionString
end

local function find_task_number_string_in_branch_name(branch)
	local _, startIndex = string.find(branch, ".0-", 1, true)
	if startIndex == nil then return nil end
	local endIndex = string.find(branch, "-", startIndex + 1, true)
	if endIndex == nil then return nil end
	local taskNumberString = string.sub(branch, startIndex, endIndex)
	if string.sub(taskNumberString, 1, 2) == "#" then
		return string.sub(taskNumberString, 3, -2)
	end
	return string.sub(taskNumberString, 2, -2)
end

local function find_description_in_branch_name(branch)
	local _, versionStartIndex = string.find(branch, ".0-", 1, true)
	if versionStartIndex == nil then return nil end
	local startIndex = string.find(branch, "-", versionStartIndex + 1, true)
	if startIndex == nil then return nil end
	return string.sub(branch, startIndex + 1)
end


this.find_odoo_version = function()
	-- First, try to obtain the Odoo version from the active git branch
	local branch = git.get_branch()
	if branch ~= nil then
		local odooVersion, _ = find_odoo_version_in_branch_name(branch)
		if odooVersion ~= nil then
			return tonumber(odooVersion)
		end
	end

	-- Then, try to obtain the Odoo version from the active Python venv
	local output = check_pip_odoo_version_output()
	if output ~= nil and output ~= "" then
		local odooVersion = find_odoo_version_in_pip_output(output)
		return tonumber(odooVersion)
	end
end

this.find_task_number = function()
	local branch = git.get_branch()
	if branch == nil then
		return nil
	end
	local string = find_task_number_string_in_branch_name(branch)
	return tonumber(string)
end

this.find_issue_description = function()
	local branch = git.get_branch()
	if branch == nil then return nil end
	return find_description_in_branch_name(branch)
end

this.get_odoo_version = function()
	if vim.b.odoo_version == nil then
		vim.b.odoo_version = this.find_odoo_version()
	end
	return vim.b.odoo_version
end

this.pick_python_interpreter = function(version)
	local python_interpreter = 'python'
	if version ~= nil then
		python_interpreter = '/home/therp/wax/' .. version .. '/wax/venv/bin/python'
	end
	return python_interpreter
end


return this
