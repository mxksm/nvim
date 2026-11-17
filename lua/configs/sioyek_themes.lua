local M = {}
local catalog = require "configs.sioyek_palettes"

local function rgb(hex)
  return { tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16) }
end

local function mix(a, b, amount)
  a, b = rgb(a), rgb(b)
  return string.format("#%02x%02x%02x", unpack(vim.tbl_map(function(i)
    return math.floor(a[i] + (b[i] - a[i]) * amount + 0.5)
  end, { 1, 2, 3 })))
end

local function luminance(hex)
  local c = rgb(hex)
  for i, value in ipairs(c) do
    value = value / 255
    c[i] = value <= 0.04045 and value / 12.92 or ((value + 0.055) / 1.055) ^ 2.4
  end
  return c[1] * 0.2126 + c[2] * 0.7152 + c[3] * 0.0722
end

local function contrast(a, b)
  a, b = luminance(a), luminance(b)
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05)
end

local function build(entry)
  local c = entry.colors
  local bg, fg = c.custom_background_color, c.custom_text_color
  local panel, selection = c.ui_background_color, c.ui_selected_background_color
  -- Annotation colors cover small areas in a PDF. Soften them for whole pages
  -- of syntax, and increase contrast where a light theme's ink needs it.
  local function accent(color)
    local result = mix(color, fg, 0.18)
    for _ = 1, 16 do
      if contrast(result, bg) >= 4.5 then break end
      result = mix(result, fg, 0.12)
    end
    return result
  end
  local red = accent(c.highlight_color_f)
  local green = accent(c.highlight_color_b)
  local blue = accent(c.link_highlight_color)
  local yellow = accent(c.search_highlight_color)
  local purple = accent(c.highlight_color_e)
  local cyan = accent(c.highlight_color_c)
  local orange = accent(c.highlight_color_d)
  local muted = mix(bg, fg, 0.55)
  local subtle = mix(bg, fg, 0.04)
  return {
    type = luminance(bg) > 0.4 and "light" or "dark",
    base_16 = {
      base00 = bg, base01 = panel, base02 = selection, base03 = muted,
      base04 = mix(bg, fg, 0.7), base05 = fg, base06 = fg, base07 = fg,
      base08 = red, base09 = orange, base0A = yellow, base0B = green,
      base0C = cyan, base0D = blue, base0E = purple, base0F = red,
    },
    base_30 = {
      white = fg, black = bg, darker_black = panel, black2 = subtle,
      one_bg = panel, one_bg2 = selection, one_bg3 = mix(bg, fg, 0.2),
      grey = mix(bg, fg, 0.4), grey_fg = muted, grey_fg2 = muted, light_grey = muted,
      red = red, baby_pink = red, pink = purple, green = green, vibrant_green = green,
      nord_blue = blue, blue = blue, yellow = yellow, sun = yellow,
      purple = purple, dark_purple = purple, teal = cyan, orange = orange, cyan = cyan,
      line = selection, statusline_bg = bg, lightbg = panel, pmenu_bg = selection, folder_bg = blue,
    },
    polish_hl = {
      defaults = {
        NormalFloat = { bg = panel, fg = c.ui_text_color },
        Pmenu = { bg = panel, fg = c.ui_text_color },
        PmenuSel = { bg = selection, fg = c.ui_selected_text_color },
        Visual = { bg = selection, fg = c.ui_selected_text_color },
      },
      tbline = { TbFill = { bg = bg }, TabLineFill = { bg = bg } },
    },
  }
end

function M.names()
  local names = {}
  for _, entry in ipairs(catalog) do names[#names + 1] = entry.name end
  table.sort(names)
  return names
end

function M.register()
  for _, entry in ipairs(catalog) do
    local value = entry
    package.preload["base46.themes." .. entry.name] = function() return build(value) end
  end
end

function M.setup_picker()
  require("nvchad.utils").list_themes = M.names
  -- Keep display names identical to Sioyek, with forgiving literal search.
  require("nvchad.themes.utils").filter = function(list, query)
    local result = {}
    local function normalized(value)
      return value:lower():gsub("é", "e"):gsub("[%s_%-]", "")
    end
    query = normalized(query)
    for _, name in ipairs(list) do
      if normalized(name):find(query, 1, true) then
        result[#result + 1] = name
      end
    end
    return result
  end
end

-- Keep the choice out of tracked configuration, so changing themes never
-- prevents a pull on another computer.
local function state_path()
  return vim.fn.stdpath("state") .. "/sioyek-theme"
end

function M.selected()
  local ok, lines = pcall(vim.fn.readfile, state_path())
  if ok and vim.tbl_contains(M.names(), lines[1]) then return lines[1] end
  return "Catppuccin Latte"
end

function M.save(name)
  assert(vim.tbl_contains(M.names(), name), "Unknown Sioyek theme")
  vim.fn.mkdir(vim.fn.stdpath("state"), "p")
  local path = state_path()
  vim.fn.writefile({ name }, path .. ".tmp")
  assert(vim.uv.fs_rename(path .. ".tmp", path))
end

function M.picker_mappings(buf)
  local state = require "nvchad.themes.state"
  -- The stock picker uses a prompt buffer and only handles TextChangedI.
  -- Use ordinary editable text so normal-mode edits/undo also filter results,
  -- without treating the prompt icon (or its byte width) as part of the query.
  for _, event in ipairs { "TextChangedI", "TextChanged" } do
    vim.api.nvim_clear_autocmds { event = event, buffer = buf }
  end
  vim.bo[buf].buftype = "nofile"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
  vim.api.nvim_win_set_cursor(state.input_win, { 1, 0 })
  vim.api.nvim_win_set_config(state.input_win, { title = " Search themes ", title_pos = "left" })
  local previous_query = ""
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP", "InsertLeave" }, {
    buffer = buf,
    callback = function()
      local query = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), " ")
      if query == previous_query then return end
      previous_query = query
      state.themes_shown = require("nvchad.themes.utils").filter(state.val, query)
      state.index = 1
      state.active_theme = state.themes_shown[1] or ""
      state.scrolled = false
      vim.bo[state.buf].modifiable = true
      local blank = {}
      for i = 1, vim.api.nvim_buf_line_count(state.buf) do blank[i] = "" end
      vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, blank)
      vim.bo[state.buf].modifiable = false
      vim.api.nvim_buf_clear_namespace(state.buf, state.ns, 0, -1)
      require("volt").redraw(state.buf, "all")
      vim.api.nvim_win_set_cursor(state.win, { 1, 0 })
      vim.api.nvim_win_call(state.win, function() vim.cmd "normal! zt" end)
      if state.themes_shown[1] then
        require("nvchad.themes.utils").reload_theme(state.themes_shown[1])
      end
    end,
  })
  local current = require("nvconfig").base46.theme
  for index, name in ipairs(state.themes_shown) do
    if name == current then
      state.index, state.active_theme = index, name
      break
    end
  end
  require("volt").redraw(state.buf, "all")
  local row = (state.index - 1) * state.scroll_step[state.style] + 1
  vim.api.nvim_win_set_cursor(state.win, { math.min(row, vim.api.nvim_buf_line_count(state.buf)), 0 })
  vim.api.nvim_win_call(state.win, function() vim.cmd "normal! zz" end)
  vim.cmd.stopinsert()
  vim.keymap.set("n", "/", "A", { buffer = buf, desc = "Search themes" })
  vim.keymap.set("i", "<Esc>", "<Esc>", { buffer = buf, desc = "Return to normal mode" })
  vim.keymap.set({ "n", "i" }, "<CR>", function()
    local name = state.themes_shown[state.index]
    if not name then return end
    M.save(name)
    require("nvchad.themes.utils").reload_theme(name)
    state.confirmed = true
    require("volt").close()
  end, { buffer = buf, desc = "Keep theme" })
end

return M
