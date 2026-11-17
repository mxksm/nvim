-- Run from the dotfiles root: nvim --headless -u NONE -i NONE -l nvim/tests/sioyek_themes.lua
local root = vim.fn.getcwd()
vim.opt.rtp:prepend(root .. "/nvim")
for _, path in ipairs(vim.fn.glob(vim.fn.stdpath("data") .. "/lazy/*", false, true)) do
  vim.opt.rtp:append(path)
end
local temp = vim.fn.tempname()
vim.fn.mkdir(temp, "p")
vim.env.XDG_STATE_HOME = temp
vim.g.base46_cache = temp .. "/base46/"
vim.o.columns, vim.o.lines = 140, 55
local catalog = require "configs.sioyek_palettes"
local themes = require "configs.sioyek_themes"
themes.register()
themes.setup_picker()
local config = require "nvconfig"
assert(#themes.names() == 26)
assert(vim.deep_equal(require("nvchad.utils").list_themes(), themes.names()))
for _, entry in ipairs(catalog) do
  config.base46.theme = entry.name
  require("base46").load_all_highlights()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  assert(normal.bg == tonumber(entry.colors.custom_background_color:sub(2), 16), entry.name .. " background")
  assert(normal.fg == tonumber(entry.colors.custom_text_color:sub(2), 16), entry.name .. " foreground")
  assert(vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false }).bg ==
    tonumber(entry.colors.ui_background_color:sub(2), 16), entry.name .. " floating panel")
  local palette = require("configs.wezterm_theme").palette()
  assert(palette.background:lower() == entry.colors.custom_background_color:lower(), entry.name .. " terminal sync")
end
local filter = require("nvchad.themes.utils").filter
assert(vim.deep_equal(filter(themes.names(), "gruvbox"), { "Gruvbox Dark", "Gruvbox Light" }))
assert(#filter(themes.names(), "rose pine") == 2, "accent-insensitive names")
assert(#filter(themes.names(), "[") == 0, "search is literal, not a Lua pattern")
themes.save("Violet Charcoal")
assert(themes.selected() == "Violet Charcoal")
package.loaded.chadrc = nil
config.base46.theme = require("chadrc").base46.theme
require("base46").load_all_highlights()
local picker = require "nvchad.themes"
picker.open()
local state = require "nvchad.themes.state"
assert(state.themes_shown[state.index] == "Violet Charcoal", "picker selects saved theme")
assert(vim.fn.mode():sub(1, 1) ~= "i", "normal mode by default")
require("nvchad.themes.api").move_up()
assert(config.base46.theme ~= "Violet Charcoal", "navigation previews")
require("volt").close()
assert(config.base46.theme == "Violet Charcoal", "cancel restores saved theme")
require("nvchad.themes").open()
state = require "nvchad.themes.state"
require("nvchad.themes.api").move_up()
local chosen = config.base46.theme
local confirm = vim.fn.maparg("<CR>", "n", false, true).callback
confirm()
assert(themes.selected() == chosen, "Enter persists the preview")
assert(config.base46.theme == chosen, "Enter keeps the preview")
vim.fn.delete(temp, "rf")
print("PASS: 26 matching palettes, highlights, terminal sync, filtered picker, preview, rollback and persistence")
vim.cmd "qa!"
