local M = {}

function M.new(props)
  local self = setmetatable({}, { __index = M })

  self.text = props.text or ""
  self.value = props.value or 50 -- Default to 50%
  self.width = props.width or 20
  self.on_change = props.on_change or function() end

  self.thumb_icon = props.thumb_icon or ""
  self.hl_active = props.hl_active or "VoltSliderActive"
  self.hl_inactive = props.hl_inactive or "VoltSliderInactive"

  return self
end

function M:render()
  local line = {}

  if self.text ~= "" then
    table.insert(line, { self.text .. " ", "Comment" })
  end

  local total_bar_width = self.width
  local thumb_width = vim.fn.strwidth(self.thumb_icon)
  local active_i = math.ceil((self.value / 100) * total_bar_width)

  -- Ensure thumb doesn't go out of bounds
  active_i = math.max(thumb_width, active_i)
  active_i = math.min(total_bar_width, active_i)

  local active_str = string.rep("━", active_i - thumb_width)
  local inactive_str = string.rep("━", total_bar_width - active_i)

  local slider_actions = {
    ui_type = "slider",
    click = function()
      -- This is a bit tricky. The click action needs to calculate the new value.
      -- The original implementation did this in a separate `M.val` function.
      -- For a component, this needs to be self-contained.
      local cursor_col = vim.api.nvim_win_get_cursor(0)[2]
      local text_width = vim.fn.strwidth(self.text) + 1
      local xpad = 2 -- This is a guess, will need to be passed in or calculated
      local relative_col = cursor_col - text_width - xpad
      local new_value = math.ceil((relative_col / self.width) * 100)

      new_value = math.max(0, math.min(100, new_value)) -- Clamp between 0 and 100

      if new_value ~= self.value then
        self.value = new_value
        self.on_change(self.value)
      end
    end,
  }

  table.insert(line, { active_str, self.hl_active, slider_actions })
  table.insert(line, { self.thumb_icon, self.hl_active, slider_actions })
  table.insert(line, { inactive_str, self.hl_inactive, slider_actions })

  -- Optional percentage text
  table.insert(line, { ("  %3d%%"):format(self.value), "Number" })

  return { line }
end

return M
