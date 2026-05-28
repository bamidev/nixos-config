return {
	'saghen/blink.cmp',
	tag = 'v1.10.2',
	config = function()
		require('blink.cmp').setup({
			keymap = { preset = "enter" },

			signature = { enabled = true },

			snippets = {
				preset = "luasnip",
			},

			sources = {
				default = { "lsp", "snippets", "path" },
				-- TODO: Configure the buffer provider so that it is only used with words of 5 characters or more.
				providers = {
					buffer = { min_keyword_length = 5 }
				},
			},

			completion = {
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 500,
				},

				ghost_text = { enabled = true },

				menu = {
					border = "none",

					draw = {
						columns = {
							{ "kind_icon", "label", "label_description", gap = 1 },
							{ "source_name" },
						},
						components = {
							source_name = {
								text = function(ctx)
									if ctx.source_name == "LSP" then
										local client = vim.lsp.get_client_by_id(ctx.item.client_id)
										return "[" .. (client and client.name or "?LSP?") .. "]"
									end
									return "[" .. ctx.source_name .. "]"
								end,
							},
						},
						treesitter = {'lsp'},
					},

					scrollbar = true,
				},
			},
		})
	end,
}
