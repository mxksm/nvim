local M = {}

function M.command(file, now)
  local helper = vim.fn.expand '~/.config/sioyek/commands/typst_source.py'
  if vim.fn.filereadable(helper) == 0 then
    error('Update the Sioyek config: commands/typst_source.py is missing')
  end
  return { 'python3', helper, 'compile', vim.fn.fnamemodify(file, ':p'),
    '--server', vim.v.servername, '--input', 'now=' .. now }
end

function M.jump(location)
  if type(location) ~= 'table' or type(location.path) ~= 'string' or
      type(location.line) ~= 'number' or vim.fn.filereadable(location.path) == 0 then
    return 'Typst source is unavailable'
  end
  local ok, err = pcall(function()
    local buf = vim.fn.bufadd(location.path)
    vim.fn.bufload(buf)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == buf then
        vim.api.nvim_set_current_win(win)
        break
      end
    end
    vim.api.nvim_set_current_buf(buf)
    local line = math.max(1, math.min(location.line, vim.api.nvim_buf_line_count(buf)))
    local text = vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1] or ''
    -- Tinymist columns count Unicode characters; Neovim cursors use bytes.
    local column = vim.str_byteindex(text, math.min(location.column or 0, vim.fn.strchars(text)))
    vim.api.nvim_win_set_cursor(0, { line, column })
    vim.cmd 'normal! zvzz'
    vim.api.nvim_exec_autocmds('User', { pattern = 'VimtexEventViewReverse' })
  end)
  return ok and 'ok' or tostring(err)
end

function M.compile_and_view()
  local file = vim.fn.filereadable('main.typ') == 1 and 'main.typ' or vim.api.nvim_buf_get_name(0)
  local args = M.command(file, os.date '%Y %m %d %H %M %S')
  local errors = {}
  vim.fn.jobstart(args, {
    stderr_buffered = true,
    on_stderr = function(_, data) errors = data end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify(table.concat(errors, '\n'), vim.log.levels.ERROR)
          return
        end
        local pdf = vim.fn.fnamemodify(file, ':p:r') .. '.pdf'
        if vim.fn.has 'mac' == 1 then
          vim.fn.jobstart({ 'open', '-a', 'sioyek', pdf }, { detach = true })
        else
          vim.fn.jobstart({ 'sioyek', pdf }, { detach = true })
        end
      end)
    end,
  })
end

return M
