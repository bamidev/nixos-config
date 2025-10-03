local this = {}


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
	return versionString
end

this.find_odoo_version = function()
	local branch = check_git_branch()
	if branch == nil then return nil end
	return find_odoo_version_in_branch_name(branch)
end


return this
