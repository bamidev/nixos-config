return function(client, bufnr)
	vim.b.lsp_server_count = vim.b.lsp_server_count and (vim.b.lsp_server_count + 1) or 1

	-- Override the textDocument/completion request callback in order to adjust the completion items to also show the source (lsp server) of the item.
	if vim.b.lsp_server_count == 2 then
		local orig_request = client.request
		client.request = function(self, method, params, callback, bufnr_req)
			if method == 'textDocument/completion' and callback then
				local orig_cb = callback
				callback = function(err, result)
					if not err and result then
						local items = result.items ~= nil and result.items or result
						if type(items) == 'table' then
							for _, item in ipairs(items) do
								item.detail = '(' .. (client.name or 'unknown?') .. ')' .. (item.detail and ' ' .. item.detail or '')
							end
						end
					end
					orig_cb(err, result)
				end
			end
			return orig_request(self, method, params, callback, bufnr_req)
		end
	end

	-- Enable autocomplete
	--[[vim.lsp.completion.enable(true, client.id, bufnr, {
		autotrigger = true,
	})]]--
end
