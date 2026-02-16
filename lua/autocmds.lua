require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

-----------------------------------------------------------
-- 🧠 AUTO INDENTATION FOR C++
-----------------------------------------------------------

autocmd("FileType", {
  pattern = "cpp",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})
