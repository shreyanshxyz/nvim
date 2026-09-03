local M = {}

M.config = {
  model = 'gemma4:e2b',
  ollama_url = 'http://localhost:11434/api/generate',
  max_diff_size = 7000,
}

local function get_staged_diff()
  local handle = io.popen('git diff --staged 2>/dev/null')
  if not handle then return nil end
  local diff = handle:read('*a')
  handle:close()
  return diff
end

local function has_staged_changes()
  local diff = get_staged_diff()
  return diff and #diff > 0
end

local function truncate_diff(diff)
  if #diff > M.config.max_diff_size then
    return diff:sub(1, M.config.max_diff_size) .. '\n... (truncated)'
  end
  return diff
end

local function call_ollama(prompt, callback)
  local body = vim.json.encode({
    model = M.config.model,
    prompt = prompt,
    stream = false,
  })

  local cmd = string.format(
    'curl -s -X POST %s -H "Content-Type: application/json" -d %s',
    M.config.ollama_url,
    vim.fn.shellescape(body)
  )

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data and #data > 0 then
        local response = table.concat(data, '')
        local ok, decoded = pcall(vim.json.decode, response)
        if ok and decoded and decoded.response then
          callback(decoded.response)
        else
          callback(nil, 'Failed to parse Ollama response')
        end
      else
        callback(nil, 'No response from Ollama')
      end
    end,
    on_stderr = function(_, _)
      callback(nil, 'Error calling Ollama. Is it running?')
    end,
  })
end

local function create_floating_buffer()
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.4)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
    title = ' Commit Message (Enter to commit, q to cancel) ',
    title_pos = 'center',
  })

  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'gitcommit')
  vim.api.nvim_buf_set_option(buf, 'buftype', 'acwrite')

  return buf, win
end

local function commit_with_message(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local message = table.concat(lines, '\n')
  message = message:gsub('^%s+', ''):gsub('%s+$', '')

  if #message == 0 then
    vim.notify('Commit message is empty', vim.log.levels.ERROR)
    return false
  end

  local tmpfile = vim.fn.tempname()
  local f = io.open(tmpfile, 'w')
  if f then
    f:write(message)
    f:close()
  end

  local result = vim.fn.system('git commit -F ' .. vim.fn.shellescape(tmpfile) .. ' 2>&1')
  local exit_code = vim.v.shell_error

  os.remove(tmpfile)

  if exit_code == 0 then
    vim.notify('Committed successfully!', vim.log.levels.INFO)
    return true
  else
    vim.notify('Commit failed: ' .. result, vim.log.levels.ERROR)
    return false
  end
end

local function setup_buffer_keymaps(buf, win)
  vim.keymap.set('n', '<CR>', function()
    if commit_with_message(buf) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, silent = true })

  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })

  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = buf,
    callback = function()
      if commit_with_message(buf) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })
end

function M.ai_commit()
  if not has_staged_changes() then
    vim.notify('No staged changes. Stage files first with :CodeDiff or git add', vim.log.levels.WARN)
    return
  end

  vim.notify('Generating commit message with ' .. M.config.model .. '...', vim.log.levels.INFO)

  local diff = truncate_diff(get_staged_diff())

  local prompt = [[Analyze the following staged git changes and generate a commit message.

Requirements:
- Output ONLY the commit message, nothing else (no explanations, no introductions)
- Write a commit message with 10-15 words
- Use conventional commits format: type(scope): description
- Be specific about WHAT changed and WHY
- Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build

Example output: feat(lsp): add clangd configuration for C++ autocompletion

Staged changes:
]] .. diff

  call_ollama(prompt, function(response, err)
    vim.schedule(function()
      if err then
        vim.notify(err, vim.log.levels.ERROR)
        return
      end

      local buf, win = create_floating_buffer()

      response = response:gsub('^%s+', ''):gsub('%s+$', '')
      local lines = vim.split(response, '\n')
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.api.nvim_win_set_cursor(win, { 1, 0 })

      setup_buffer_keymaps(buf, win)
      vim.notify('Message generated! Edit if needed, then press <Enter> to commit', vim.log.levels.INFO)
    end)
  end)
end

return M
