{ pkgs, ... }: ''
  -- Bootstrap pckr.nvim
  local function bootstrap_pckr()
    local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"

    if not (vim.uv or vim.loop).fs_stat(pckr_path) then
      vim.fn.system({
        'git',
        'clone',
        "--filter=blob:none",
        'https://github.com/lewis6991/pckr.nvim',
        pckr_path
      })

      -- Pin pckr to a specific commit
      vim.fn.system({
        'git',
      'reset',
      '--hard',
      'dcc0e2766d7a3a1911287fef7060ac07908cf376'
      })
    end

    vim.opt.rtp:prepend(pckr_path)
  end

  bootstrap_pckr()


  -- Pick the theme variant depending on the time of year
  local season = "winter" -- Not the exact current season, but closer to the rythm of the earth anyway.
  local month = os.date("*t")["month"]
  if month >= 3 and month <= 5 then
    season = "spring"
  else if month >= 6 and month <= 8 then
    season = "summer"
  else if month >= 9 and month <= 11 then
    season = "fall"
  end end end


  -- Plugins
  local pckr = require("pckr")
  pckr.setup {
    autoinstall = true,
    autoremove = true,
    git = {
      cmd = "${pkgs.git}/bin/git",
    }
  }
  pckr.add {
    require('plugins.dap'),
    require('plugins.dap-python'),
    require('plugins.feline'),
    require('plugins.gitsigns'),
    require('plugins.indent-blankline'),
    require('plugins.lua-snip'),
    require('plugins.ufo'),
    {
      "danymat/neogen",
      tag = "2.20.0",
      config = function()
        local neogen = require('neogen')
        neogen.setup {
          snippet_engine = "luasnip"
        }

        local opts = { noremap = true, silent = true }
        vim.keymap.set("n", "<Leader>cg", neogen.generate, opts)
      end,
    },
    {
      "ellisonleao/gruvbox.nvim",
      tag = "2.0.0",
      config = function()
        if not vim.o.termguicolors then
          return
        end

        if season == "fall" then
          vim.o.background = "dark"
        else if season == "spring" then
          vim.o.background = "light"
        else
          return
        end end
        vim.cmd.colorscheme("gruvbox")
      end
    },
    {
      "lukas-reineke/headlines.nvim",
      tag = "v5.0.0",
      requires = "nvim-treesitter/nvim-treesitter",
      config = function() require('headlines').setup() end,
    },
    { 'neovim/nvim-lspconfig', tag = 'v2.5.0' },
    { "nvim-neotest/nvim-nio", tag = "v1.10.1" },
    { "nvim-tree/nvim-web-devicons", tag = "v0.100" },
    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.8",
      requires = "nvim-lua/plenary.nvim",
      config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
      end
    },
    {
      "nvim-treesitter/nvim-treesitter",
      tag = "v0.10.0",
      config = function()
        require('nvim-treesitter.configs').setup {
          auto_install = true,
          sync_install = false,

          highlight = {
            enable = true,
          },
          indent = {
            enable = {'python'},
          },
        }
      end
    },
    {
      "nvim-treesitter/nvim-treesitter-context",
      tag = "v1.0.0",
      config = function()
        require('treesitter-context').setup({
          enable = true,
          mode = 'topline',
        })
      end
    },
    {
      'onsails/lspkind.nvim', commit = '3ddd1b4edefa425fda5a9f95a4f25578727c0bb3',
      config = function()
        require('lspkind').init()
      end
    },
    {
      "preservim/nerdtree",
      tag = "7.1.3",
      config = function()
        vim.keymap.set({'n', 'v', 'x'}, '<C-t>', ':NERDTreeToggle<cr>')
        vim.keymap.set({'n', 'v', 'x'}, '<C-f>', ':NERDTreeFind<cr>')
      end
    },
    {
      "rcarriga/nvim-dap-ui",
      commit = "cf91d5e",
      requires = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
      },
      config = function()
        local dapui = require("dapui")
        dapui.setup()

        vim.keymap.set('n', '<F12>', dapui.toggle)
      end
    },
    { "ryanoasis/vim-devicons", tag = "v0.11.0" },
    {
      "sainnhe/everforest",
      tag = "v0.3.0",
      config = function()
        if not vim.o.termguicolors then
          return
        end

        if season == "winter" then
          vim.o.background = "dark"
        else if season == "summer" then
          vim.o.background = "light"
        else
          return
        end end
        vim.g.everforest_enable_italic = true
        vim.cmd.colorscheme("everforest")
      end
    },
    {
      "soulis-1256/eagle.nvim",
      commit = "dd1a28c4d8626fbe85580b0a9ed8f88d77a26da1",
      config = function()
        vim.o.mousemoveevent = true
        require("eagle").setup {
          keyboard_mode = true,
          mouse_mode = true,
        }

        --vim.keymap.set('n', '<Tab>', ':EagleWin<CR>', { noremap = true, silent = true })
      end,
    },
    { "uga-rosa/utf8.nvim", commit = "954cbbadabe5cd19f202e918fec191d64eea7766" },
  }
''
