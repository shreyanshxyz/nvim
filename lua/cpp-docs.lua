local M = {}

M.open_cppreference = function()
  local word = vim.fn.expand('<cword>')
  if word == '' then
    vim.notify('No word under cursor', vim.log.levels.WARN)
    return
  end

  local container_map = {
    ['vector'] = 'vector',
    ['string'] = 'basic_string',
    ['map'] = 'map',
    ['unordered_map'] = 'unordered_map',
    ['set'] = 'set',
    ['unordered_set'] = 'unordered_set',
    ['list'] = 'list',
    ['deque'] = 'deque',
    ['stack'] = 'stack',
    ['queue'] = 'queue',
    ['priority_queue'] = 'priority_queue',
    ['array'] = 'array',
    ['pair'] = 'pair',
    ['tuple'] = 'tuple',
    ['optional'] = 'optional',
    ['variant'] = 'variant',
    ['shared_ptr'] = 'shared_ptr',
    ['unique_ptr'] = 'unique_ptr',
    ['weak_ptr'] = 'weak_ptr',
  }

  local search_term = container_map[word] or word
  local url = string.format('https://en.cppreference.com/mwiki/index.php?search=%s', search_term)
  
  vim.ui.open(url)
  vim.notify(string.format('Opening cppreference for: %s', word), vim.log.levels.INFO)
end

M.hover_with_docs = function()
  vim.lsp.buf.hover()
  
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local is_cpp = false
  for _, client in ipairs(clients) do
    if client.name == 'clangd' then
      is_cpp = true
      break
    end
  end
  
  if is_cpp then
    vim.defer_fn(function()
      vim.notify('Press <leader>K to open cppreference docs', vim.log.levels.INFO, { timeout = 2000 })
    end, 500)
  end
end

return M
