local c = require('plugins.feline.common')
local git = require('utils.git')


return {
	c.fancy_component(
		function()
			return git.get_branch() or ''
		end,
		'oceanblue',
		'left'
	)
}
