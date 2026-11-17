-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = require("configs.sioyek_themes").selected(),
  theme_toggle = { "Catppuccin Latte", "Catppuccin Mocha" },
  transparency = false,
	hl_override = {
	  Comment = { italic = true },
	 	["@comment"] = { italic = true },
    LineNr = { fg = "grey" },
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
  mappings = require("configs.sioyek_themes").picker_mappings,
}

M.plugins = "plugins"

return M
