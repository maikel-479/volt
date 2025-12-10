local api = vim.api
local nvmark_state = require "volt.state"
local redraw = require("volt").redraw
local cycle_clickables = require("volt.utils").cycle_clickables

local MouseMove = vim.keycode "<MouseMove>"
local LeftMouse = vim.keycode "<LeftMouse>"
local map = vim.keymap.set

local get_item_from_col = function(tb, n)
  for _, val in ipairs(tb) do
    if val.col_start <= n and val.col_end >= n then
      return val
    end
  end
end

local run_func = function(foo)
  if type(foo) == "function" then
    foo()
  elseif type(foo) == "string" then
    vim.cmd(foo)
  end
end

local function handle_click(buf, by, row, col, win)
  local v = nvmark_state.get(buf)

  if not row then
    local cursor_pos = api.nvim_win_get_cursor(0)
    row, col = cursor_pos[1], cursor_pos[2]
  end

  if v.clickables[row] then
    local virt = get_item_from_col(v.clickables[row], col)

    if virt and (by ~= "keyb" or virt.ui_type == "slider") then
      local actions = virt.actions
      run_func(type(actions) == "table" and actions.click or actions)
    end

    if win and api.nvim_win_is_valid(win) then
      vim.schedule(function()
        api.nvim_win_set_cursor(win, { 1, 1 })
      end)
    end
  end
end

local function set_cursormoved_autocmd(buf)
  api.nvim_create_autocmd("CursorMoved", {
    buffer = buf,
    callback = function()
      handle_click(buf, "keyb")
    end,
  })
end

-- We need to keep track of the currently hovered item to handle "unhover" events.
local currently_hovered = nil

local function handle_hover(buf_state, buf, row, col)
  local virt_item = nil
  if buf_state.hoverables[row] then
    virt_item = get_item_from_col(buf_state.hoverables[row], col)
  end

  -- If we are hovering over a new item
  if virt_item and virt_item ~= currently_hovered then
    -- 1. Unhover the previous item if there was one
    if currently_hovered and currently_hovered.unhover and currently_hovered.unhover.callback then
      currently_hovered.unhover.callback()
      if currently_hovered.unhover.redraw then
        redraw(buf, currently_hovered.unhover.redraw)
      end
    end

    -- 2. Hover the new item
    if virt_item.hover and virt_item.hover.callback then
      virt_item.hover.callback()
      if virt_item.hover.redraw then
        redraw(buf, virt_item.hover.redraw)
      end
    end

    currently_hovered = virt_item

  -- If we are no longer hovering over anything
  elseif not virt_item and currently_hovered then
    if currently_hovered.unhover and currently_hovered.unhover.callback then
      currently_hovered.unhover.callback()
      if currently_hovered.unhover.redraw then
        redraw(buf, currently_hovered.unhover.redraw)
      end
    end
    currently_hovered = nil
  end
end

local buf_mappings = function(buf)
  set_cursormoved_autocmd(buf)

  map("n", "<CR>", function()
    handle_click(buf)
  end, { buffer = buf })

  map("n", "<Tab>", function()
    cycle_clickables(buf, 1)
  end, { buffer = buf })

  map("n", "<S-Tab>", function()
    cycle_clickables(buf, -1)
  end, { buffer = buf })
end

local M = {}

M.bufs = {}

M.add = function(val)
  if type(val) == "table" then
    for _, buf in ipairs(val) do
      table.insert(M.bufs, buf)
      buf_mappings(buf)
    end
  else
    table.insert(M.bufs, val)
    buf_mappings(val)
  end
end

M.remove = function(buf)
  for i, bufid in ipairs(M.bufs) do
    if bufid == buf then
      table.remove(M.bufs, i)
      break
    end
  end
end

M.enable = function()
  vim.g.extmarks_events = true
  vim.o.mousemev = true

  vim.on_key(function(key)
    local mousepos = vim.fn.getmousepos()
    local cur_win = mousepos.winid
    local cur_buf = api.nvim_win_get_buf(cur_win)

    if vim.tbl_contains(M.bufs, cur_buf) then
      local row, col = mousepos.line, mousepos.column - 1
      local buf_state = nvmark_state.get(cur_buf)

      if not buf_state then
        return
      end

      if key == MouseMove then
        handle_hover(buf_state, cur_buf, row, col)
      elseif key == LeftMouse then
        handle_click(cur_buf, "mouse", row, col, cur_win)
      end
    end
  end)
end

return M
