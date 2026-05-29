return {
	settings = {
		pylsp = {
			-- flake8 tends to have a few better configuration options than pycodestyle.
			configurationSources = {"flake8"},
			plugins = {
				autopep8 = { enabled = true },
				black = { enabled = true },
				flake8 = { enabled = true },
				isort = { enabled = true },
				jedi_completion = { enabled = true, fuzzy = true },
				jedi_definition = { enabled = true },
				jedi_hover = { enabled = true },
				jedi_references = { enabled = true },
				jedi_signature_help = { enabled = true },
				jedi_symbols = { enabled = true },
				jedi_type_definition = { enabled = true },
				-- Should already be used by flake8 itself.
				mccabe = { enabled = false },
				pycodestyle = { enabled = false },
				pydocstyle = { enabled = true },
				-- Not needed when flake8 is available.
				pyflakes = { enabled = false },
				pylint = { enabled = true },
				rope_autoimport = { enabled = true },
			},
		},
	},
}
