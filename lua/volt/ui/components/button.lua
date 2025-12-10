local M = {}

function M.new(props)
  local self = setmetatable({}, { __index = M })

  self.text = props.text or "Button"
  self.on_click = props.on_click or function() end
  self.is_hovered = false

  return self
end

function M:render()
  local text = self.is_hovered and "> " .. self.text .. " <" or "  " .. self.text .. "  "
  local highlight = self.is_hovered and "VoltButtonHover" or "VoltButton"

  return {
    { text, highlight, {
      click = function()
        self.on_click()
      end,
      hover = {
        callback = function()
          self.is_hovered = true
        end,
        redraw = "all",
      },
      unhover = {
        callback = function()
          self.is_hovered = false
        end,
        redraw = "all",
      },
    } },
  }
end

return M
