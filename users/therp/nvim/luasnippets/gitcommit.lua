local luasnip = require("luasnip")
local i = luasnip.insert_node
local s = luasnip.snippet
local t = luasnip.text_node


local function check_git_branch()
	local c = io.popen("git rev-parse --abbrev-ref HEAD")
	if c == nil then
		return nil
	end

	local output = c:read("*l")
	c:close()
	return output
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

local function find_task_number()
	local branch = check_git_branch()
	if branch == nil then
		return nil
	end
	local string = find_task_number_string_in_branch_name(branch)
	return tonumber(string)
end

local function prefix(code)
	local result = '[' .. string.upper(code) .. '] '
	local task_number = find_task_number()
	if task_number ~= nil then
		result = result .. '#' .. task_number .. ' '
	end
	return result
end


return {
	s("add", {
		t(prefix('ADD')),
		i(1, '...')
	}),
	s("fix", {
		t(prefix('FIX')),
		i(1, '...')
	}),
	s("imp", {
		t(prefix('IMP')),
		i(1, '...')
	}),
	s("rem", {
		t(prefix('REM')),
		i(1, '...')
	}),
}
