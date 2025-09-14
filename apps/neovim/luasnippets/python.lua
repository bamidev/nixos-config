local ls = require('luasnip')

local c = ls.choice_node
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node


return {
	s('class', {
		t('class '),
		i(1, 'ClassName'),
		c(2, {
			t(''),
			{ t('('), i(1, 'ParentClass'), t(')'), },
		}),
		t({':', '    '})
	})
}
