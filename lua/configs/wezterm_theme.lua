local M = {}
local generation = 0
local last_palette

local function hex(value)
  return type(value) == "number" and string.format("#%06x", value) or nil
end

function M.palette()
  -- link=false resolves through the focused window's winhl remapping. A theme
  -- picker's Normal can be a background-only float style instead of the theme.
  -- Follow global links ourselves, without inheriting that window's palette.
  local name, seen, normal = "Normal", {}, {}
  while not seen[name] do
    seen[name] = true
    normal = vim.api.nvim_get_hl(0, { name = name, link = true })
    if not normal.link then break end
    name = normal.link
  end
  -- A transparent theme intentionally has no background to share.
  if not normal.bg or not normal.fg then return nil end
  local colors = { background = hex(normal.bg), foreground = hex(normal.fg) }
  for _, range in ipairs { { "ansi", 0 }, { "brights", 8 } } do
    local palette = {}
    for i = 0, 7 do
      local color = vim.g["terminal_color_" .. (range[2] + i)]
      if type(color) ~= "string" or not color:match("^#%x%x%x%x%x%x$") then break end
      palette[#palette + 1] = color
    end
    if #palette == 8 then colors[range[1]] = palette end
  end
  return colors
end

function M.publish(force)
  if not vim.env.WEZTERM_PANE or #vim.api.nvim_list_uis() == 0 then return end
  local colors = M.palette()
  if not colors then return end
  local signature = vim.json.encode(colors)
  if not force and signature == last_palette then return end
  last_palette = signature
  -- A nonce also refreshes the colors when returning to another Neovim pane.
  local payload = vim.json.encode { colors = colors, nonce = tostring(vim.uv.hrtime()) }
  local sequence = "\027]1337;SetUserVar=NVIM_THEME=" .. vim.base64.encode(payload) .. "\007"
  if vim.api.nvim_ui_send then vim.api.nvim_ui_send(sequence)
  else vim.api.nvim_chan_send(2, sequence) end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("WezTermTheme", { clear = true })
  local function schedule()
    generation = generation + 1
    local pending = generation
    vim.defer_fn(function()
      if pending == generation then M.publish() end
    end, 60)
  end
  vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "ColorScheme" }, {
    group = group, callback = schedule,
  })
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group, callback = function() M.publish(true) end,
  })
  -- Plugin versions differ in which theme events they emit. At the end of an
  -- input cycle, inspect the actual highlights too; send only changed palettes.
  -- This is event-driven, with no timer polling or redraw on unchanged input.
  vim.api.nvim_create_autocmd("SafeState", {
    group = group, callback = function() M.publish() end,
  })
  -- NvChad's picker, including previews and Escape rollback, uses this event.
  vim.api.nvim_create_autocmd("User", { group = group, pattern = "NvThemeReload", callback = schedule })
  schedule()
end

return M
