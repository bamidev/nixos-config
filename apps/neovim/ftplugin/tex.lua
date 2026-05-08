vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.tex",
	callback = function()
		if vim.fn.filereadable("build.sh") == 1 then
			vim.fn.jobstart({ "./build.sh" })
		end
	end
})
