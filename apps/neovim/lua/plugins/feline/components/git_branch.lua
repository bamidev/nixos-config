local c = require('plugins.feline.common')
local git = require('utils.git')
local utf8 = require('utf8')


local branch = c.fancy_component(
	function()
		return git.get_branch() or ''
	end,
	'bg_aqua',
	'right'
)
branch.icon = utf8.char(0xE0A0) .. ' '
branch.update = {'BufEnter'}


return {
	branch
}
