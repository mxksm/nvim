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
  changed_themes = {
    gruvbox = {
      -- Muted warm accents in both syntax and UI/terminal palettes.
      base_16 = {
        base08 = "#c98278", base09 = "#c99a73", base0A = "#c4ae7a",
        base0B = "#a5ae82", base0C = "#91ae94", base0D = "#8fa6a0",
        base0E = "#b394a1", base0F = "#b88b71",
      },
      base_30 = {
        red = "#c98278", baby_pink = "#b57670", pink = "#ba91a0",
        green = "#a5ae82", vibrant_green = "#a5ae82",
        nord_blue = "#8fa6a0", blue = "#829c9d",
        yellow = "#b8a175", sun = "#c4ae7a",
        purple = "#a7a6b4", dark_purple = "#b394a1",
        teal = "#88a096", orange = "#c99a73", cyan = "#91aaa3",
      },
    },
  },
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
