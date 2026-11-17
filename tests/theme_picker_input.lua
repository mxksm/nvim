-- Exercise real input/events in a separate Neovim event loop, including reopen.
-- Run: nvim --headless -u NONE -i NONE -l nvim/tests/theme_picker_input.lua
local root = vim.fn.getcwd()
local temp = vim.fn.tempname()
vim.fn.mkdir(temp, "p")
local child = vim.fn.jobstart({ vim.v.progpath, "--embed", "--headless", "-u", "NONE", "-i", "NONE" }, { rpc = true })
local function lua(code, ...)
  return vim.rpcrequest(child, "nvim_exec_lua", code, { ... })
end
local function expect(code, message)
  assert(vim.wait(3000, function() return lua(code) end, 20), message)
end
local function input(keys)
  vim.rpcrequest(child, "nvim_input", keys)
end
local ok, err = pcall(function()
  lua([[
    local root, temp = ...
    vim.opt.rtp:prepend(root .. "/nvim")
    for _, path in ipairs(vim.fn.glob(vim.fn.stdpath("data") .. "/lazy/*", false, true)) do
      vim.opt.rtp:append(path)
    end
    vim.env.XDG_STATE_HOME = temp
    vim.g.base46_cache = temp .. "/base46/"
    vim.o.columns, vim.o.lines = 140, 55
    local themes = require "configs.sioyek_themes"
    themes.register()
    themes.setup_picker()
    themes.save("Violet Charcoal")
    require("base46").load_all_highlights()
  ]], root, temp)
  for iteration = 1, 3 do
    lua('require("nvchad.themes").open()')
    expect('return vim.fn.mode() == "n"', "picker starts in normal mode")
    input("/graphite")
    expect([[return vim.deep_equal(require("nvchad.themes.state").themes_shown,
      { "Catppuccin Graphite", "Graphite" })]], "live search filters on opening " .. iteration)
    expect('return vim.fn.mode() == "i"', "search works before leaving insert mode")
    input("<Esc>j")
    expect('return require("nvconfig").base46.theme == "Graphite"', "j previews filtered result")
    input("<Esc>")
    expect('return require("nvconfig").base46.theme == "Violet Charcoal"', "cancel restores theme")
  end
end)
vim.fn.jobstop(child)
vim.fn.jobwait({ child }, 1000)
vim.fn.delete(temp, "rf")
assert(ok, err)
print("PASS: real typing filters themes across three picker openings")
vim.cmd "qa!"
