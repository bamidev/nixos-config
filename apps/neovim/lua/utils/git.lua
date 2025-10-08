local this = {}


this.get_branch = function()
	local c = io.popen("git rev-parse --abbrev-ref HEAD 2>/dev/null")
	if c == nil then
		return nil
	end

	local output = c:read("*l")
	c:close()
	return output
end


return this
