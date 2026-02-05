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

--- old typst compilation
--map("n", "<leader>lo", ':lua require("nvterm.terminal").send("typst watch main.typ", "horizontal")<CR>:lua vim.fn.jobstart({"zsh", "-c", "source ~/.zshrc && pdf"}, {detach = true})<CR>', { desc = "Typst watch + PDF", noremap = true, silent = true })

--- new typst stuff


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

map("n", "<leader>lt", function()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_pos = vim.api.nvim_win_get_cursor(cur_win)  -- {line, col}

  nvterm.toggle("horizontal", 1)

  -- show full log if there was an error
  if not typst_state.last_ok and typst_state.last_error then
    nvterm.send("clear", "horizontal", 1)
    nvterm.send("typst compile main.typ", "horizontal", 1)
  end

  vim.api.nvim_set_current_win(cur_win)
  vim.api.nvim_win_set_cursor(cur_win, cur_pos)  -- restore exact cursor
end, { desc = "Toggle Typst log", noremap = true, silent = true })

-- Autosave + compile on change
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)

    if name:sub(-4) == ".typ" and vim.bo[buf].modified then
      vim.cmd("silent write")        -- keep your autosave
      typst_compile_silent()         -- trigger compile immediately
    end

    if name:sub(-4) == ".tex" and vim.bo[buf].modified then
      vim.cmd("silent write")        -- keep your autosave
      typst_compile_silent()         -- trigger compile immediately
    end
  end,
})

-----------------------------------------------------------
-- 🧰 TERMINAL
-----------------------------------------------------------

map("t", "<C-j>", [[<C-\><C-n>]], { desc = "Exit terminal mode", noremap = true, silent = true })

-----------------------------------------------------------
-- 🪟 QUICKFIX TOGGLE
-----------------------------------------------------------

function ToggleQuickfix()
  local qf_exists = vim.fn.getqflist({ winid = 1 }).winid ~= 0
  if qf_exists then
    vim.cmd("cclose")
    vim.g.quickfix_open = false
  else
    vim.cmd("copen")
    vim.g.quickfix_open = true
  end
end

map("n", "<leader>q", ":lua ToggleQuickfix()<CR>", { desc = "Toggle quickfix", noremap = true, silent = true })

-----------------------------------------------------------
-- ⌨️ INSERT REMAPS
-----------------------------------------------------------

map("i", "kk", "^", { desc = "Insert caret" })
map("i", "jj", "_", { desc = "Insert underscore" })
map("i", "ii", "*", { desc = "Insert asterisk" })

--map("n", "<leader>tt", ":lua require('base46').toggle_transparency()<CR>", { noremap = true, silent = true, desc = "Toggle Background Transparency" })
