local luasnip = require("luasnip")
local odoo = require('utils.odoo')
local i = luasnip.insert_node
local s = luasnip.snippet
local t = luasnip.text_node


local function prefix(code)
	local result = '[' .. string.upper(code) .. '] '
	local task_number = odoo.find_task_number()
	if task_number ~= nil then
		result = result .. '#' .. task_number .. ' '
	end
	return result
end


return {
	s("add", {
		t(prefix('ADD')),
		i(1)
	}),
	s("fix", {
		t(prefix('FIX')),
		i(1)
	}),
	s("imp", {
		t(prefix('IMP')),
		i(1)
	}),
	s("rem", {
		t(prefix('REM')),
		i(1)
	}),
}
