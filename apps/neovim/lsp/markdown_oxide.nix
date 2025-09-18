{ pkgs }: ''
  return {
    cmd = {'${pkgs.markdown-oxide}/bin/markdown-oxide'},
    on_attach = require('autocomplete'),
    filetypes = {'markdown'},
    root_markers = {'.git', '.obsidian', '.moxide.toml'},
  }
''
