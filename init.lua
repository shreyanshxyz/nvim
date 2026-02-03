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
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.clipboard = 'unnamedplus'

require('lazy').setup({
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { {'nvim-lua/plenary.nvim'} }
  },
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v4.x',
    lazy = true,
    config = false,
  },
  {
    'neovim/nvim-lspconfig',
    lazy = true,
  },
  {
    'williamboman/mason.nvim',
    lazy = true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = true,
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
          theme = 'catppuccin'
        }
      })
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('catppuccin-latte')
    end,
  },
})

vim.keymap.set('n', '<leader>e', ':Neotree toggle position=left<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>o', ':Neotree reveal position=left<CR>', { noremap = true, silent = true })
vim.keymap.set({'n', 'v'}, '<C-c>', '"+y', { noremap = true, silent = true })
vim.keymap.set('n', '<C-x>', '"+dd', { noremap = true, silent = true })
vim.keymap.set('v', '<C-x>', '"+x', { noremap = true, silent = true })

require('lsp')
vim.api.nvim_set_keymap('n', '<leader>pf', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ps', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })
