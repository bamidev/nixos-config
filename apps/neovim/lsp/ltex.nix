{ pkgs, ... }: ''
  return {
    cmd = {'${pkgs.ltex-ls}/bin/ltex-ls'},
    filetypes = {'latex', 'markdown', 'plaintext', 'rst', 'tex'},
    settings = {
      ltex = {
        enabled = {'latex', 'markdown', 'plaintext', 'restructedtext', 'tex'},
        language = 'en-US',
      }
    },
    root_markers = {'.git'},
  }
''
