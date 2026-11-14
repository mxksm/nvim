local M = {}
local generation = 0

local function hex(value)
  return type(value) == "number" and string.format("#%06x", value) or nil
end

function M.palette()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
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

function M.publish()
  if not vim.env.WEZTERM_PANE or #vim.api.nvim_list_uis() == 0 then return end
  local colors = M.palette()
  if not colors then return end
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
  vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "ColorScheme", "FocusGained" }, {
    group = group, callback = schedule,
  })
  -- NvChad's picker, including previews and Escape rollback, uses this event.
  vim.api.nvim_create_autocmd("User", { group = group, pattern = "NvThemeReload", callback = schedule })
  schedule()
end

return M
