{ pkgs }: ''
  local function switch_source_header(client, bufnr)
    local method_name = 'textDocument/switchSourceHeader'
    local params = vim.lsp.util.make_text_document_params(bufnr)
    client:request(method_name, params, function(err, result)
      if err then
        error(tostring(err))
      end
      if not result then
        vim.notify('corresponding file cannot be determined')
        return
      end
      vim.cmd.edit(vim.uri_to_fname(result))
    end, bufnr)
  end

  vim.lsp.config('ccls', {
    cmd = { '${pkgs.ccls}/bin/ccls' },
    on_attach = function(client, bufnr)
      require('autocomplete')(client, bufnr)
      vim.api.nvim_buf_create_user_command(bufnr, 'LspCclsSwitchSourceHeader', function()
        switch_source_header(client, bufnr)
      end, { desc = 'Switch between source/header' })
    end,
  })
''
