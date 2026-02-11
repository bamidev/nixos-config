local this = {}


this.get_branch = function()
	if vim.g.gitsigns_head ~= nil then
		return vim.g.gitsigns_head
	end

	local c = io.popen("git rev-parse --abbrev-ref HEAD 2>/dev/null")
	if c == nil then
		return nil
	end

	local output = c:read("*l")
	c:close()
	vim.g.gitsigns_head = output
	return output
end


return this
