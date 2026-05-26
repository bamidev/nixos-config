return {
	'saghen/blink.cmp',
	tag = 'v1.10.2',
	config = function()
		require('blink.cmp').setup({
			keymap = { preset = "enter" },

			snippets = {
				preset = "luasnip",
			},

			sources = {
				default = { "lsp", "snippets", "path", "buffer" },
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
