require "nvchad.autocmds"
require("configs.wezterm_theme").setup()

local autocmd = vim.api.nvim_create_autocmd

-- VimTeX calls this only in the editor that accepted the source location.
-- Ask that terminal pane to focus itself, instead of raising an arbitrary
-- WezTerm window or starting another Neovim instance.
autocmd("User", {
  group = vim.api.nvim_create_augroup("SioyekSourceJump", { clear = true }),
  pattern = "VimtexEventViewReverse",
  callback = function()
    vim.cmd "normal! zvzz"
    if vim.env.WEZTERM_PANE and #vim.api.nvim_list_uis() > 0 then
      local token = vim.base64.encode(tostring(vim.uv.hrtime()))
      local sequence = "\027]1337;SetUserVar=SIOYEK_SOURCE_JUMP=" .. token .. "\007"
      if vim.api.nvim_ui_send then
        vim.api.nvim_ui_send(sequence)
      else
        -- Older Neovim versions forward stderr to their attached terminal.
        vim.api.nvim_chan_send(2, sequence)
      end
    end
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
