local M = {}
local watcher

local favorites = {
  flexoki = "Flexoki Dark", monokai = "Monokai Midnight", slate = "Slate",
  tokyo_dracula = "Tokyo Dracula", gray_5 = "Cocoa", gruvbox_light = "Gruvbox Light",
  catppuccin_latte = "Catppuccin Latte", white = "Paper White",
}

function M.setup(on_applied)
  if watcher then watcher:stop(); watcher:close(); watcher = nil end
  if not vim.env.WEZTERM_PANE then return function() end end
  local config_home = vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")
  local path = vim.env.WEZTERM_THEME_REQUEST or (config_home .. "/wezterm/.theme-request.json")
  local basename = vim.fn.fnamemodify(path, ":t")
  local receipt = vim.fn.stdpath("state") .. "/wezterm-theme-request"
  local ok, saved = pcall(vim.fn.readfile, receipt)
  local last_id = ok and saved[1] or nil

  local function consume()
    local file = io.open(path, "r")
    if not file then return end
    local contents = file:read(4096)
    file:close()
    local valid, request = pcall(vim.json.decode, contents or "")
    if not valid or type(request) ~= "table" or type(request.id) ~= "string"
      or #request.id > 128 or request.id == last_id then return end
    local name = favorites[request.preset]
    if not name then return end
    local applied, err = pcall(function()
      require("nvchad.themes.utils").reload_theme(name)
      require("configs.sioyek_themes").save(name)
      vim.fn.mkdir(vim.fn.stdpath("state"), "p")
      vim.fn.writefile({ request.id }, receipt)
    end)
    if not applied then
      vim.notify("Unable to apply WezTerm theme: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    last_id = request.id
    on_applied()
  end

  -- Watch the directory because WezTerm replaces the request file atomically.
  -- Receipts are per process while running, so every open editor can consume it.
  watcher = vim.uv.new_fs_event()
  if watcher then
    local started = watcher:start(vim.fn.fnamemodify(path, ":h"), {}, function(err, filename)
      if not err and (not filename or filename == basename) then
        vim.schedule(consume)
      end
    end)
    if not started then watcher:close(); watcher = nil end
  end
  local group = vim.api.nvim_create_augroup("WezTermThemeRequests", { clear = true })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group, callback = function()
      if watcher then watcher:stop(); watcher:close(); watcher = nil end
    end,
  })
  consume()
  return consume
end

return M
