{ pkgs, ... }: ''
  return {
  	"L3MON4D3/LuaSnip",
  	tag = "v2.4.0",
  	run = "${pkgs.gnumake}/bin/make install_jsregexp || make install_jsregexp",
  	config = function()
  		local ls = require("luasnip")

  		require('luasnip.loaders.from_lua').load()

  		vim.keymap.set({"i"}, "<S-tab>", function() ls.expand() end, {silent = true})
  		vim.keymap.set({"i", "s"}, "<A-tab>", function() ls.jump(1) end, {silent = true})
  		vim.keymap.set({"i", "s"}, "<C-tab>", function() ls.jump(-1) end, {silent = true})
  
  		vim.keymap.set({"i", "s"}, "<C-e>", function()
  			if ls.choice_active() then
  				ls.change_choice(1)
  			end
  		end, {silent = true})
  	end,
  }
''
