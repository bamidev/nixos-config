local this = {}
local git = require('utils.git')


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


this.find_odoo_version = function()
	local branch = git.get_branch()
	if branch == nil then return nil end
	local odooVersion, _ = find_odoo_version_in_branch_name(branch)
	return odooVersion
end


this.find_task_number = function()
	local branch = git.get_branch()
	if branch == nil then
		return nil
	end
	local string = find_task_number_string_in_branch_name(branch)
	return tonumber(string)
end


this.issue_info = function()
	local branch = git.get_branch()
	if branch == nil then return nil end
	local odooVersion, _ = find_odoo_version_in_branch_name(branch)
	return odooVersion
end


return this
