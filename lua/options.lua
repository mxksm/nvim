require "nvchad.options"

local opt = vim.opt
local g = vim.g
local wo = vim.wo

-----------------------------------------------------------
-- 🪶 UI / LOOK
-----------------------------------------------------------

opt.cursorline = true
opt.guicursor = "" -- vertical block cursor
wo.number = true
wo.relativenumber = true
opt.cursorlineopt = "both"

-- Visual selection highlight
--vim.api.nvim_set_hl(0, "Visual", { fg = "White", bg = "DarkGrey" })
--vim.cmd("hi LineNr guifg=#6c707b")

-----------------------------------------------------------
-- 🧩 INDENTATION / FORMATTING
-----------------------------------------------------------

-- Default indentation
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.expandtab = true
opt.wrap = true
opt.linebreak = true

-----------------------------------------------------------
-- 🔭 OTHER SETTINGS
-----------------------------------------------------------

opt.spell = true
opt.clipboard = ""
g.copilot_no_tab_map = true
g.vimtex_view_method = "sioyek"
g.vimtex_quickfix_mode = 0
g.quickfix_open = false
g.copilot_enabled = false
