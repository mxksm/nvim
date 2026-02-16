-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}


M.base46 = {
	theme = "aylin",

  transparency = false,
	hl_override = {
	  Comment = { italic = true },
	 	["@comment"] = { italic = true },
    Visual = { fg = "white", bg = "darkgrey" },
    LineNr = { fg = "#6c707b" },
	},
}

M.ui = {
  transparency = true,
  nvdash = {
    load_on_startup = true,
  },
  tabufline = {
    lazyload = false
  },
}

M.plugins = "plugins"

return M
