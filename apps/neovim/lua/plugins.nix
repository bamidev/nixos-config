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
  local season = "winter"
  local month = os.date("*t")["month"]
  if month >= 4 and month <= 6 then
    season = "spring"
  else if month >= 7 and month <= 9 then
    season = "summer"
  else if month >= 10 and month <= 12 then
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
    {
      "j-hui/fidget.nvim",
      tag = "v1.6.1",
      config = function()
        require("fidget").setup {}
      end,
    },
    {
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
    },{
      'lewis6991/gitsigns.nvim',
      tag = 'v1.0.2',
      config = function()
        local gitsigns = require('gitsigns')
        gitsigns.setup({
          on_attach = function()
            vim.keymap.set('n', '<C-b>', gitsigns.toggle_current_line_blame)
          end
        })
      end,
    },
    {
      "lukas-reineke/headlines.nvim",
      tag = "v5.0.0",
      requires = "nvim-treesitter/nvim-treesitter",
      config = function()
        require('headlines').setup()
      end,
    },
    {
      "lukas-reineke/indent-blankline.nvim",
      tag = "v3.9.0",
      config = function()
        local highlight = {
          "CursorColumn",
          "Whitespace",
        }
        require("ibl").setup {
          indent = { highlight = highlight, char = "" },
          whitespace = {
            highlight = highlight,
            remove_blankline_trail = false,
          },
          scope = { enabled = false },
        }
      end
    },
    {
      "mfussenegger/nvim-dap",
      tag = "0.10.0",
      config = function()
        local dap = require("dap")
        vim.keymap.set('n', '<F1>', dap.continue)
        vim.keymap.set('n', '<F2>', dap.step_over)
        vim.keymap.set('n', '<F3>', dap.step_into)
        vim.keymap.set('n', '<F7>', dap.toggle_breakpoint)
        vim.keymap.set('n', '<F11>', dap.repl.open)
      end
    },
    {
      "mfussenegger/nvim-dap-python",
      commit = "030385d03363988370adaa5cf21fa465daddb088",
      requires = "mfussenegger/nvim-dap",
      config = function()
        require("dap-python").setup("python")

        local dap = require("dap")
        dap.configurations.python = {
          {
            type = "python";
            request = "launch";
            name = "Launch Odoo from within Waft";
            program = "''${workspaceFolder}/custom/src/odoo/odoo-bin";
            pythonPath = function()
              return "''${workspaceFolder}/.venv/bin/python"
            end
          },
          {
            type = "python";
            request = "launch";
            name = "Launch Odoo from within Wax";
            program = "''${workspaceFolder}/wax/repos/odoo/odoo-bin";
            pythonPath = function()
              return "''${workspaceFolder}/wax/venv/bin/python"
            end
          },
          {
            type = "python";
            request = "launch";
            name = "Launch Python File";
            program = "''${file}";
            pythonPath = function()
              return "python"
            end
          },
        }
      end
    },
    {
      "morhetz/gruvbox",
      tag = "v3.0.1-rc.0",
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
        --vim.g.airline_theme = 'gruvbox'
      end
    },
    {
      "nvim-neotest/nvim-nio",
      tag = "v1.10.1",
    },
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
    {
      "vim-airline/vim-airline",
      tag = "v0.11",
      config = function()
        -- The gruvbox theme doesn't work well with airline
        if vim.o.termguicolors and vim.g.colors_name ~= "gruvbox" then
          vim.g.airline_powerline_fonts = 1
        else
          vim.g.airline_symbols_ascii = 1
        end
      end
    },
    {
      "kevinhwang91/nvim-ufo",
      --tag = "v1.5.0",
      -- Revert to the last known working commit to prevent the following bug:
      -- https://github.com/kevinhwang91/nvim-ufo/issues/309
      commit = "5b75cf5fdb74054fc8badb2e7ca9911dc0470d94",
      requires = {
        "kevinhwang91/promise-async",
        "nvim-treesitter/nvim-treesitter",
      },
      config = function()
        -- Settings required for the ufo plugin
        vim.o.foldcolumn = '1'
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true


        local ufo = require('ufo')
        ufo.setup({
          provider_selector = function(_, _, _)
            return {'treesitter', 'indent'}
          end,
          close_fold_kinds_for_ft = {
            default = {"function_definition", "imports"},
            python = {"class_definition", "function_definition", "imports"},
            cpp = {"class_specifier", "function_definition"},
            rust = {"function_item", "impl_item", "struct_item", "use_declaration"},
            xml = {"element"},
          }
        })

        -- TODO: Close all folds except the above kinds
        --vim.keymap.set('n', '<C-a>', ufo.closeAllFolds)
      end
    },
  }
''
