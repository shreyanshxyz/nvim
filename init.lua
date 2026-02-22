vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.opt.number = true
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true
vim.opt.completeopt = {'menuone', 'noselect'}
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.clipboard = 'unnamedplus'

require('lazy').setup({
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false,
  },
  {
    'HiPhish/rainbow-delimiters.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'nvim-cmp' },
    config = function()
      require('nvim-autopairs').setup({
        check_ts = true,
        ts_config = {
          lua = { 'string' },
          javascript = { 'template_string' },
        }
      })
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },
  {
    'kylechui/nvim-surround',
    version = '*',
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup()
    end,
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    main = 'ibl',
    config = function()
      require('ibl').setup({
        indent = { char = '│' },
        scope = { enabled = true },
      })
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { {'nvim-lua/plenary.nvim'} }
  },
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v4.x',
    config = false,
  },
  {
    'neovim/nvim-lspconfig',
  },
  {
    'williamboman/mason.nvim',
  },
  {
    'williamboman/mason-lspconfig.nvim',
  },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'saadparwaiz1/cmp_luasnip',
      'l3mon4d3/luasnip',
      'hrsh7th/cmp-nvim-lsp',
    },
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    cmd = {'Neotree'},
    config = function()
      require('neo-tree').setup({
        close_if_last_window = false,
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_by_name = { '.next', 'node_modules', '.git', '__pycache__', '.pytest_cache', '.venv', 'venv', '.DS_Store' },
          },
          follow_current_file = { enabled = true },
          hijack_netrw_behavior = 'disabled',
        },
        window = {
          position = 'left',
          width = 40,
        },
        default_component_configs = {
          indent = {
            with_expanders = true,
          }
        }
      })
    end,
  },
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'Gdiffsplit', 'Gwrite' },
  },
  {
    'Exafunction/windsurf.vim',
    event = 'BufEnter',
    config = function()
      vim.g.codeium_manual = false
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'everforest'
        }
      })
    end,
  },
  {
    'sainnhe/everforest',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.everforest_background = 'medium'
      vim.g.everforest_enable_italic = 1
      vim.cmd.colorscheme('everforest')
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      {
        '<leader>?',
        function() require('which-key').show({ global = false }) end,
        desc = 'Buffer Local Keymaps',
      },
    },
  },
  {
    'esmuellert/codediff.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    cmd = 'CodeDiff',
    opts = {
      highlights = {
        line_insert = 'DiffAdd',
        line_delete = 'DiffDelete',
        char_brightness = 1.4,
      },
      diff = {
        disable_inlay_hints = true,
        max_computation_time_ms = 5000,
        original_position = 'left',
        cycle_next_hunk = true,
        cycle_next_file = true,
      },
      explorer = {
        position = 'left',
        width = 40,
        initial_focus = 'explorer',
        view_mode = 'tree',
        focus_on_select = true,
      },
      history = {
        position = 'bottom',
        height = 15,
        initial_focus = 'history',
      },
      keymaps = {
        view = {
          quit = 'q',
          toggle_explorer = '<leader>b',
          next_hunk = ']c',
          prev_hunk = '[c',
          next_file = ']f',
          prev_file = '[f',
          diff_get = 'do',
          diff_put = 'dp',
          open_in_prev_tab = 'gf',
          toggle_stage = '-',
          stage_hunk = '<leader>hs',
          unstage_hunk = '<leader>hu',
          discard_hunk = '<leader>hr',
          show_help = 'g?',
        },
        explorer = {
          select = '<CR>',
          hover = 'K',
          refresh = 'R',
          toggle_view_mode = 'i',
          stage_all = 'S',
          unstage_all = 'U',
          restore = 'X',
        },
        history = {
          select = '<CR>',
          toggle_view_mode = 'i',
        },
        conflict = {
          accept_incoming = '<leader>ct',
          accept_current = '<leader>co',
          accept_both = '<leader>cb',
          discard = '<leader>cx',
          next_conflict = ']x',
          prev_conflict = '[x',
          diffget_incoming = '2do',
          diffget_current = '3do',
        },
      },
    },
  },
})

vim.keymap.set('n', '<leader>e', ':Neotree toggle position=left<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>o', ':Neotree reveal position=left<CR>', { noremap = true, silent = true })
vim.keymap.set({'n', 'v'}, '<C-c>', '"+y', { noremap = true, silent = true })
vim.keymap.set('n', '<C-x>', '"+dd', { noremap = true, silent = true })
vim.keymap.set('v', '<C-x>', '"+x', { noremap = true, silent = true })
vim.keymap.set({'n', 'i'}, '<C-s>', '<cmd>w<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>dd', '<cmd>CodeDiff<CR>', { noremap = true, silent = true, desc = 'Open git diff explorer' })
vim.keymap.set('n', '<leader>df', '<cmd>CodeDiff file HEAD<CR>', { noremap = true, silent = true, desc = 'Diff current file vs HEAD' })
vim.keymap.set('n', '<leader>dh', '<cmd>CodeDiff history<CR>', { noremap = true, silent = true, desc = 'Open file history' })
vim.keymap.set('n', '<leader>dm', '<cmd>CodeDiff merge<CR>', { noremap = true, silent = true, desc = 'Open merge conflict view' })

vim.keymap.set('n', '<leader>cc', function() require('git-commit').ai_commit() end, { desc = 'AI commit (Ollama)' })
vim.keymap.set('n', '<leader>cm', '<cmd>Git commit -v<CR>', { desc = 'Manual commit with diff' })
vim.keymap.set('n', '<leader>ca', '<cmd>Git commit --amend<CR>', { desc = 'Amend last commit' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'codediff',
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

require('lsp')

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    vim.schedule(function()
      require('nvim-treesitter.config').setup({
        highlight = { enable = true },
        indent = { enable = true },
      })
    end)
  end,
})

vim.keymap.set('n', '<leader>pf', function()
  require('telescope.builtin').find_files({ hidden = true, no_ignore = true, file_ignore_patterns = { '.next', 'node_modules', '.git', '__pycache__', '.pytest_cache', '.venv', 'venv', '.DS_Store' } })
end, { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ps', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })

vim.keymap.set('n', 'K', function()
  require('cpp-docs').hover_with_docs()
end, { noremap = true, silent = true, desc = 'LSP hover with docs hint' })
vim.keymap.set('n', '<leader>K', function()
  require('cpp-docs').open_cppreference()
end, { noremap = true, silent = true, desc = 'Open cppreference docs' })
