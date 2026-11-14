-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

-- nice dark theme
-- theme = "chadtain",

M.base46 = {
	theme = "chadtain",

  transparency = false,
	hl_override = {
	  Comment = { italic = true },
	 	["@comment"] = { italic = true },
    Visual = { fg = "white", bg = "darkgrey" },
    LineNr = { fg = "#6c707b" },
    TbFill = { link = "Normal" },
    TabLineFill = { link = "Normal" },
	},
}

M.ui = {
  transparency = false,
  nvdash = {
    load_on_startup = true,
  },
  tabufline = {
--    enabled = false, -- This completely hides the top buffer/tab bar
    lazyload = false,
    order = { "treeOffset", "buffers", "tabs" },
  },
}

M.themepicker = {
  mappings = function(buf)
    vim.cmd.stopinsert()
    vim.keymap.set("i", "<Esc>", "<Esc>", { buffer = buf, desc = "Return to normal mode" })
  end,
}

M.plugins = "plugins"

return M
