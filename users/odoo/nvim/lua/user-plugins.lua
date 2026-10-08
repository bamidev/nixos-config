return {
	{
		'greggh/claude-code.nvim',
		tag = 'v0.4.3',
		requires = 'nvim-lua/plenary.nvim',
		config = function()
			require('claude-code').setup()
		end
	}
}
