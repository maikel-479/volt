local M = {}
local Button = require("volt.ui.components.button")
local LinearLayout = require("volt.ui.components.layout")

function M.new(props)
  local self = setmetatable({}, { __index = M })

  self.tabs = props.tabs or {} -- Table of strings
  self.active_tab = props.active_tab or 1
  self.on_tab_change = props.on_tab_change or function() end

  self.hl_active = props.hl_active or "VoltTabActive"
  self.hl_inactive = props.hl_inactive or "VoltTabInactive"

  self._buttons = {}
  self:_create_buttons()

  return self
end

function M:_create_buttons()
  self._buttons = {}
  for i, tab_name in ipairs(self.tabs) do
    local is_active = (i == self.active_tab)
    table.insert(self._buttons, Button.new({
      text = tab_name,
      on_click = function()
        if not is_active then
          self.active_tab = i
          self.on_tab_change(i, tab_name)
          -- Re-create buttons to update their active state visually
          self:_create_buttons()
        end
      end,
    }))
  end
end

function M:render()
  -- For now, we render tabs as a horizontal layout of buttons.
  -- A more advanced implementation would have proper tab styling.

  local button_renders = {}
  for i, button in ipairs(self._buttons) do
    local is_active = (i == self.active_tab)
    local text = button.text
    local rendered_button = button:render()[1] -- Button renders a single line
    local new_text
    local new_hl

    if is_active then
      new_text = "│ " .. text .. " │"
      new_hl = self.hl_active
    else
      new_text = "  " .. text .. "  "
      new_hl = self.hl_inactive
    end
    rendered_button[1][1] = new_text
    rendered_button[1][2] = new_hl
    table.insert(button_renders, rendered_button[1])
  end

  local top_line = {}
  local bottom_line = {}
  for i, tab_name in ipairs(self.tabs) do
    local hchar = string.rep("─", vim.fn.strwidth(tab_name) + 2)
    local hl = (i == self.active_tab) and self.hl_active or self.hl_inactive
    table.insert(top_line, { "┌" .. hchar .. "┐", hl })
    table.insert(bottom_line, { "└" .. hchar .. "┘", hl })
    if i ~= #self.tabs then
      table.insert(top_line, { " ", "Normal" })
      table.insert(bottom_line, { " ", "Normal" })
    end
  end

  return {
    top_line,
    { table.unpack(button_renders) },
    bottom_line,
  }
end

return M
