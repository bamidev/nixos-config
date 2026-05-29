vim.lsp.config('pylsp', {
	cmd = {'pylsp'},
	filetypes = {'python'},
	settings = require('pylsp').settings,
	root_markers = {'requirements.txt', '.git'},
	capabilities = require('lsp.capabilities'),
	handlers = {
          ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
              if result and result.diagnostics then
                  for _, diag in ipairs(result.diagnostics) do
                      if diag.source == 'pydocstyle' then
                          diag.severity = vim.diagnostic.severity.HINT
                      end
                  end
              end
              vim.lsp.handlers['textDocument/publishDiagnostics'](err, result, ctx, config)
          end
      }
})
