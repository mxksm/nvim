require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
--map("i", "jk", "<ESC>")

map("n", "j", function()
  return vim.v.count == 0 and "gj" or "j"
end, { expr = true, desc = "Visual line down" })

map("n", "k", function()
  return vim.v.count == 0 and "gk" or "k"
end, { expr = true, desc = "Visual line up" })


-----------------------------------------------------------
-- 🧠 GENERAL / UTILITY MAPPINGS
-----------------------------------------------------------

-- Save file with Enter
map("n", "<CR>", ":w<CR>", { desc = "Save file", noremap = true, silent = true })
map("n", "<leader><leader>", ":w<CR>", { desc = "Save file", noremap = true, silent = true })

-- Move to end and center
map("n", "G", "Gzz", { desc = "Go to end of file and center" })

-- Don't overwrite clipboard on paste
-- map({ "n", "x" }, "p", "P")
map("x", "p", '"_dP')

-----------------------------------------------------------
-- 🤖 COPILOT
-----------------------------------------------------------

map("n", "<leader>ce", ':Lazy load copilot.vim<CR>:Copilot enable<CR>:Copilot status<CR>:echo "Copilot Enabled"<CR>', { desc = "Enable Copilot", noremap = true, silent = true })
map("n", "<leader>cd", ':Copilot disable<CR>:echo "Copilot Disabled"<CR>', { desc = "Disable Copilot", noremap = true, silent = true })
map("n", "<leader>pa", ':Lazy load copilot.vim<CR>:Copilot panel<CR>:echo "Copilot Panel"<CR>', { desc = "Open Copilot Panel", noremap = true, silent = true })
map("i", "<C-J>", 'copilot#Accept("<CR>")', { expr = true, silent = true, desc = "Accept Copilot suggestion" })

-----------------------------------------------------------
-- 🔍 TELESCOPE
-----------------------------------------------------------

map("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files", noremap = true, silent = true })
map("n", "<leader>fw", ":Telescope live_grep<CR>", { desc = "Search words", noremap = true, silent = true })

-----------------------------------------------------------
-- 📄 LATEX / TYPST
-----------------------------------------------------------

-- Function for LaTeX compile + view
local function la_compile()
  vim.cmd("VimtexCompileSS")
  vim.cmd("VimtexView")
end

map("n", "<leader>la", la_compile, { desc = "LaTeX compile + view", noremap = true, silent = true })
map("n", "<leader>cc", ":VimtexCompile<CR>", { desc = "Compile LaTeX", noremap = true, silent = true })
map("n", "<leader>pd", ':lua vim.fn.jobstart({"zsh", "-c", "source ~/.zshrc && pdf"}, {detach = true})<CR>', { desc = "Open PDF", noremap = true, silent = true })
map("n", "<leader>lo", ':lua require("nvterm.terminal").send("typst watch main.typ", "horizontal")<CR>:lua vim.fn.jobstart({"zsh", "-c", "source ~/.zshrc && pdf"}, {detach = true})<CR>', { desc = "Typst watch + PDF", noremap = true, silent = true })

local nvterm = require("nvterm.terminal")

local typst_state = {
  last_ok = true,
  last_error = nil,
}

local function typst_compile_silent()
  vim.fn.jobstart(
    { "typst", "compile", "main.typ" },
    {
      stdout_buffered = true,
      stderr_buffered = true,

      on_stderr = function(_, data)
        if data and #data > 0 then
          typst_state.last_error = table.concat(data, "\n")
        end
      end,

      on_exit = function(_, code)
        vim.schedule(function()
          if code == 0 then
            typst_state.last_ok = true
            typst_state.last_error = nil
            vim.api.nvim_echo(
              { { "Typst: compilation successful", "None" } },
              false,
              {}
            )
          else
            typst_state.last_ok = false

            local short = "Typst: compilation failed"
            if typst_state.last_error then
              for line in typst_state.last_error:gmatch("[^\n]+") do
                if line ~= "" then
                  short = "Typst error: " .. line
                  break
                end
              end
            end

            vim.api.nvim_echo({ { short, "ErrorMsg" } }, false, {})
          end
        end)
      end,
    }
  )
end

local typst_timer = nil
local latex_timer = nil

local function debounce(timer_ref, delay, fn)
  if timer_ref.timer then
    timer_ref.timer:stop()
    timer_ref.timer:close()
  end

  timer_ref.timer = vim.loop.new_timer()
  timer_ref.timer:start(delay, 0, vim.schedule_wrap(fn))
end

local typst_timer_ref = {}

local function typst_compile_debounced()
  debounce(typst_timer_ref, 500, function()
    typst_compile_silent()
  end)
end

local latex_timer_ref = {}

local function latex_compile_debounced()
  debounce(latex_timer_ref, 500, function()
    vim.cmd("VimtexCompileSS")
  end)
end

-- Autosave + compile on change
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)

    if name:sub(-4) == ".typ" then
      vim.cmd("silent write")
      typst_compile_debounced()
    --elseif name:sub(-4) == ".tex" then
    --  vim.cmd("silent write")
    --  latex_compile_debounced()
    end
  end,
})


local latex_float_win = nil
local latex_float_buf = nil

local function toggle_quickfix()
  local cur_win = vim.api.nvim_get_current_win()  -- remember current window
  local qf_exists = vim.fn.getqflist({ winid = 1 }).winid ~= 0

  if qf_exists then
    vim.cmd("cclose")
    vim.g.quickfix_open = false
  else
    vim.cmd("copen")       -- open quickfix
    vim.cmd("wincmd p")    -- go back to previous window immediately
    vim.g.quickfix_open = true
  end

  -- restore focus just in case
  vim.api.nvim_set_current_win(cur_win)
end

local function toggle_latex_quickfix_float()
  if latex_float_win and vim.api.nvim_win_is_valid(latex_float_win) then
    vim.api.nvim_win_close(latex_float_win, true)
    latex_float_win = nil
    latex_float_buf = nil
    return
  end

  local qf = vim.fn.getqflist()
  local lines = {}

  for _, item in ipairs(qf) do
    if item.text and item.text ~= "" then
      for line in item.text:gmatch("[^\n]+") do
        table.insert(lines, line)
      end
    end
  end

  if #lines == 0 then
    vim.notify("LaTeX: no quickfix entries", vim.log.levels.INFO)
    return
  end

  latex_float_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(latex_float_buf, 0, -1, false, lines)

  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  latex_float_win = vim.api.nvim_open_win(latex_float_buf, false, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })
end

local function toggle_typst_terminal()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_pos = vim.api.nvim_win_get_cursor(cur_win)

  if not typst_state.last_ok and typst_state.last_error then
    nvterm.toggle("float", 1)

    vim.defer_fn(function()
      -- FULL reset: clears scrollback + screen
      nvterm.send([[printf '\033[3J\033c']], "float", 1)
      nvterm.send("typst compile main.typ", "float", 1)
    end, 20)
  else
    vim.notify("Typst: last compilation successful", vim.log.levels.INFO)
  end

  vim.api.nvim_set_current_win(cur_win)
  vim.api.nvim_win_set_cursor(cur_win, cur_pos)
end

vim.keymap.set("n", "<leader>q", function()
  local filename = vim.api.nvim_buf_get_name(0)

  if filename:sub(-4) == ".typ" then
    toggle_typst_terminal()
  elseif filename:sub(-4) == ".tex" then
    --toggle_quickfix()
    toggle_latex_quickfix_float()
  end
end, { desc = "Toggle Typst or LaTeX log/quickfix", silent = true })

-----------------------------------------------------------
-- 🧰 TERMINAL
-----------------------------------------------------------

map("t", "<C-j>", [[<C-\><C-n>]], { desc = "Exit terminal mode", noremap = true, silent = true })

-----------------------------------------------------------
-- ⌨️ INSERT REMAPS
-----------------------------------------------------------

map("i", "kk", "^", { desc = "Insert caret" })
map("i", "jj", "_", { desc = "Insert underscore" })
map("i", "ii", "*", { desc = "Insert asterisk" })

--map("n", "<leader>tt", ":lua require('base46').toggle_transparency()<CR>", { noremap = true, silent = true, desc = "Toggle Background Transparency" })
