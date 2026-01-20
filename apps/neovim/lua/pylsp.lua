return {
	settings = {
		pylsp = {
			configurationSources = {"flake8"},
			plugins = {
				flake8 = { enabled = true },
				jedi_completion = { enabled = true, fuzzy = true },
				jedi_definition = { enabled = true },
				jedi_hover = { enabled = true },
				jedi_references = { enabled = true },
				jedi_signature_help = { enabled = true },
				jedi_symbols = { enabled = true },
				jedi_type_definition = { enabled = true },
				pycodestyle = { enabled = false },
				pydocstyle = { enabled = true },
				pyflakes = { enabled = false },
				pylint = {
					enabled = true,
					args = {
						"--disable=unknown-option-value,unrecognized-option",
					},
				},
			},
		},
	},
}
