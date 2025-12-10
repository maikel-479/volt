local M = {}

-- props:
--   - children: a table of component instances
--   - orientation: "vertical" (default) or "horizontal"
function M.new(props)
  local self = setmetatable({}, { __index = M })

  self.children = props.children or {}
  self.orientation = props.orientation or "vertical"

  return self
end

-- This render function will produce a `lines` table that can be consumed
-- by a Volt layout section.
function M:render()
  local lines = {}

  if self.orientation == "vertical" then
    for _, child in ipairs(self.children) do
      -- Each component's render method should return a table of lines.
      local child_lines = child:render()
      for _, line in ipairs(child_lines) do
        table.insert(lines, line)
      end
    end
  else -- horizontal (simplified for now)
    local combined_line = {}
    for _, child in ipairs(self.children) do
      -- This simplification assumes each child renders to a single line.
      local child_lines = child:render()
      if #child_lines > 0 then
        for _, segment in ipairs(child_lines[1]) do
          table.insert(combined_line, segment)
        end
        -- Add a spacer between components
        table.insert(combined_line, { "  ", "Normal" })
      end
    end
    if #combined_line > 0 then
      -- Remove the last spacer
      table.remove(combined_line)
    end
    table.insert(lines, combined_line)
  end

  return lines
end

return M
