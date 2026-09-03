local lsp_zero = require('lsp-zero')

local mise_shims = vim.fn.expand('~/.local/share/mise/shims')
vim.env.PATH = table.concat({
  vim.fn.stdpath('data') .. '/mason/bin',
  mise_shims,
  vim.env.PATH,
}, ':')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {'ts_ls', 'clangd', 'gopls', 'pyright', 'rust-analyzer'},
  handlers = {
    lsp_zero.default_setup,
    ['clangd'] = function()
      require('lspconfig').clangd.setup({
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          '--pch-storage=memory',
        },
      })
    end,
    ['rust-analyzer'] = function()
      require('lspconfig').rust_analyzer.setup({
        settings = {
          ['rust-analyzer'] = {
            procMacro = { enable = true },
            cargo = {
              buildScripts = { enable = true },
            },
          },
        },
      })
    end,
  }
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    {name = 'nvim_lsp'},
    {name = 'luasnip'},
  }
})
