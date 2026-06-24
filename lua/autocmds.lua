require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-----------------------------------------------------------
-- ✂️ WRAP LONG LINES
-----------------------------------------------------------

local wrap_group = augroup("WrapAtOneTen", { clear = true })

autocmd({ "BufEnter", "FileType" }, {
  group = wrap_group,
  callback = function()
    vim.opt_local.textwidth = 110
    vim.opt_local.formatoptions:append "t"
  end,
})

-----------------------------------------------------------
-- 🧠 AUTO INDENTATION FOR C++
-----------------------------------------------------------

autocmd("FileType", {
  pattern = "cpp",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})
