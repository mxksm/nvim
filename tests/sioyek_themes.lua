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
require("which-key.colors").setup()
assert(#themes.names() == 26)
assert(vim.deep_equal(require("nvchad.utils").list_themes(), themes.names()))
for _, entry in ipairs(catalog) do
  config.base46.theme = entry.name
  require("base46").load_all_highlights()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  assert(normal.bg == tonumber(entry.colors.custom_background_color:sub(2), 16), entry.name .. " background")
  assert(normal.fg == tonumber(entry.colors.custom_text_color:sub(2), 16), entry.name .. " foreground")
  assert(vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false }).bg ==
    normal.bg, entry.name .. " floating background matches editor")
  assert(vim.api.nvim_get_hl(0, { name = "WhichKeyNormal", link = false }).bg ==
    normal.bg, entry.name .. " command hints match editor")
  for _, group in ipairs { "FloatBorder", "SioyekTerminalBorder", "WhichKeyBorder" } do
    local border = vim.api.nvim_get_hl(0, { name = group, link = false })
    assert(border.bg == normal.bg and border.fg ~= normal.bg, entry.name .. " visible " .. group)
  end
  local palette = require("configs.wezterm_theme").palette()
  assert(palette.background:lower() == entry.colors.custom_background_color:lower(), entry.name .. " terminal sync")
end
local filter = themes.filter
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
local function keys(input)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(input, true, false, true), "xt", false)
  -- Flush the normal-mode change notification in this synchronous test runner.
  vim.api.nvim_exec_autocmds("TextChanged", { buffer = state.input_buf })
end
keys("/gruvbox<Esc>")
assert(vim.api.nvim_buf_get_lines(state.input_buf, 0, 1, false)[1] == "gruvbox", "slash edits the query")
assert(vim.deep_equal(state.themes_shown, { "Gruvbox Dark", "Gruvbox Light" }), "typing filters themes")
assert(config.base46.theme == "Gruvbox Dark", "first result previews immediately")
keys("j")
assert(config.base46.theme == "Gruvbox Light", "normal j navigates filtered themes")
keys("Ix<Esc>")
assert(#state.themes_shown == 0, "nonmatching prefix clears results")
keys("0x")
assert(vim.deep_equal(state.themes_shown, { "Gruvbox Dark", "Gruvbox Light" }), "normal x updates search")
keys("u")
assert(vim.api.nvim_buf_get_lines(state.input_buf, 0, 1, false)[1] == "xgruvbox", "undo restores query")
assert(#state.themes_shown == 0, "undo updates search")
keys("ggdG")
assert(#state.themes_shown == 26, "normal deletion restores all themes")
keys("iNO SUCH THEME<Esc>")
assert(#state.themes_shown == 0, "no matches clears results")
assert(#vim.api.nvim_buf_get_extmarks(state.buf, state.ns, 0, -1, {}) == 0, "no stale result labels")
keys("j<CR>")
assert(vim.api.nvim_win_is_valid(state.input_win), "empty results cannot confirm")
keys("ggdGirose pine<Esc>")
assert(#state.themes_shown == 2, "editing recovers from empty results")
require("nvchad.themes.api").move_up()
assert(config.base46.theme ~= "Violet Charcoal", "navigation previews")
require("volt").close()
assert(config.base46.theme == "Violet Charcoal", "cancel restores saved theme")
require("nvchad.themes").open()
state = require "nvchad.themes.state"
keys("/graphite<Esc>")
assert(vim.deep_equal(state.themes_shown, { "Catppuccin Graphite", "Graphite" }), "search survives closing and reopening picker")
require("nvchad.themes.api").move_up()
local chosen = config.base46.theme
local confirm = vim.fn.maparg("<CR>", "n", false, true).callback
confirm()
assert(themes.selected() == chosen, "Enter persists the preview")
assert(config.base46.theme == chosen, "Enter keeps the preview")
-- Check the actual Option+I mapping, including reuse after a theme change.
require "mappings"
vim.o.shell = "/bin/sh"
local toggle_terminal = vim.fn.maparg("<A-i>", "n", false, true).callback
toggle_terminal()
local terminal_buf = vim.api.nvim_get_current_buf()
local function check_terminal_surface()
  local remaps = {}
  for from, to in vim.wo.winhighlight:gmatch("([^,:]+):([^,]+)") do remaps[from] = to end
  assert(remaps.Normal == "NormalFloat" and remaps.NormalFloat == "NormalFloat", "terminal uses floating surface")
  local border = vim.api.nvim_get_hl(0, { name = remaps.FloatBorder, link = false })
  local panel = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  assert(border.bg == normal.bg and panel.bg == normal.bg, "terminal and frame match editor background")
  assert(border.fg ~= normal.bg, "terminal boundary stays visible")
end
check_terminal_surface()
toggle_terminal()
require("nvchad.themes.utils").reload_theme("Paper White")
toggle_terminal()
assert(vim.api.nvim_get_current_buf() == terminal_buf, "toggle reuses shell")
check_terminal_surface()
vim.fn.jobstop(vim.b[terminal_buf].terminal_job_id)
toggle_terminal()
vim.fn.delete(temp, "rf")
print("PASS: 26 matching palettes, highlights, terminal sync, filtered picker, preview, rollback and persistence")
vim.cmd "qa!"
