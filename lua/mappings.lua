require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-----------------------------------------------------------
-- 🧠 GENERAL / UTILITY MAPPINGS
-----------------------------------------------------------

-- Save file with Enter
map("n", "<CR>", ":w<CR>", { desc = "Save file", noremap = true, silent = true })

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



