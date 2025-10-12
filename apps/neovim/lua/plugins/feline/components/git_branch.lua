local c = require('plugins.feline.common')
local git = require('utils.git')
local utf8 = require('utf8')


local branch = c.fancy_component(
	function()
		return git.get_branch() or ''
	end,
	'oceanblue',
	'left'
)
-- FIXME: Gives an error for some reason:
--branch.icon = utf8.char(0xE0A0) .. ' '


return {
	branch
}
