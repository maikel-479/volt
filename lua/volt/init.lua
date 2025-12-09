local M = {}
local api = vim.api
local map = vim.keymap.set
local draw = require "volt.draw"
local state = require "volt.state"
local utils = require "volt.utils"

local get_section = function(tb, name)
  return tb[name]
end

M.gen_data = function(data)
  for _, info in ipairs(data) do
    local v = state.create(info.buf)

    local buf = info.buf

    v.clickables = {}
    v.hoverables = {}
    v.xpad = info.xpad
    v.layout = {} -- Use a map for faster lookups
    v.ns = info.ns
    v.buf = buf

    local row = 0
    for _, value in ipairs(info.layout) do
      v.layout[value.name] = value
      local lines = value.lines(buf)
      value.row = row
      row = row + #lines
    end

    v.h = row
  end
end

M.redraw = function(buf, names)
  local v = state.get(buf)

  if not v then
    return
  end

  if names == "all" then
    for _, section in pairs(v.layout) do
      draw(buf, section)
    end
    return
  end

  local function redraw_one(name)
    local section = get_section(v.layout, name)
    if section then
      draw(buf, section)
    end
  end

  if type(names) == "string" then
    redraw_one(names)
    return
  end

  for _, name in ipairs(names) do
    redraw_one(name)
  end
end

M.set_empty_lines = function(buf, n, w)
  local empty_lines = {}

  for _ = 1, n, 1 do
    table.insert(empty_lines, string.rep(" ", w))
  end

  api.nvim_buf_set_lines(buf, 0, -1, true, empty_lines)
end

M.mappings = function(val)
  for _, buf in ipairs(val.bufs) do
    local v = state.get(buf)
    if v then
      v.val = val
    end

    -- cycle bufs
    map("n", "<C-t>", function()
      utils.cycle_bufs(val.bufs)
    end, { buffer = buf })

    -- close
    map("n", "q", function()
      utils.close(val)
    end, { buffer = buf })

    map("n", "<ESC>", function()
      utils.close(val)
    end, { buffer = buf })

    if val.winclosed_event then
      vim.api.nvim_create_autocmd("WinClosed", {
        buffer = buf,
        callback = function()
          vim.schedule(function()
            if state.get(buf) then
              utils.close(val)
            end
          end)
        end,
      })
    end
  end
end

M.run = function(buf, opts)
  vim.bo[buf].filetype = "VoltWindow"

  if opts.custom_empty_lines then
    opts.custom_empty_lines()
  else
    M.set_empty_lines(buf, opts.h, opts.w)
  end

  require "volt.highlights"

  M.redraw(buf, "all")

  api.nvim_set_option_value("modifiable", false, { buf = buf })

  if not vim.g.extmarks_events then
    require("volt.events").enable()
  end
end

M.toggle_func = function(open_func, ui_state, buf)
  if ui_state then
    open_func()
  else
    M.close(buf)
  end
end

M.close = function(buf)
  buf = buf or api.nvim_get_current_buf()
  local v = state.get(buf)
  if v and v.val then
    utils.close(v.val)
  end
end

return M
