require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

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
