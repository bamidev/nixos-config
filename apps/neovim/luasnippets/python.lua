local ls = require('luasnip')

local c = ls.choice_node
local f = ls.function_node
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node


local function init_body(args, _, _)
	if args[1][1] == '' then
		return '        pass'
	end

	local lines = {}
	for arg in string.gmatch(args[1][1], '%a+') do
		table.insert(lines, '        self.' .. arg .. ' = ' .. arg)
	end
	table.insert(lines, '')
	return lines
end


return {
	s('class', {
		t('class '),
		i(1, 'ClassName'),
		c(2, {
			{ t('('), i(1, 'ParentClass'), t(')'), },
			t(''),
		}),
		t({':', '    def __init__(self'}),
		i(3),
		t({'):', ''}),
		f(init_body, {3}, {}),
	})
}
