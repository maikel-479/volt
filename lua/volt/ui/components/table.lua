local M = {}

local border_chars = {
  mid = { top = "┬", bot = "┴", none = "┼" },
  corners_left = { top = "┌", bot = "└", none = "├" },
  corners_right = { top = "┐", bot = "┘", none = "┤" },
}

local function get_column_widths(data, width)
  if #data == 0 then
    return {}, 0
  end

  local num_cols = #data[1]
  local max_widths = {}
  for i = 1, num_cols do
    max_widths[i] = 0
  end

  for _, row in ipairs(data) do
    for i, cell in ipairs(row) do
      local cell_text = type(cell) == "table" and cell[1] or tostring(cell)
      max_widths[i] = math.max(max_widths[i], vim.fn.strwidth(cell_text))
    end
  end

  local total_content_width = 0
  for _, w in ipairs(max_widths) do
    total_content_width = total_content_width + w
  end

  -- Each cell has 2 padding, each column has a 1 char border
  local total_padding_and_border = (num_cols * 2) + (num_cols + 1)
  local available_width = width - total_padding_and_border
  local extra_width_per_col = math.floor((available_width - total_content_width) / num_cols)

  if extra_width_per_col < 0 then
    extra_width_per_col = 0
  end

  local final_widths = {}
  for _, w in ipairs(max_widths) do
    table.insert(final_widths, w + extra_width_per_col)
  end

  return final_widths
end

function M.new(props)
  local self = setmetatable({}, { __index = M })

  self.title = props.title
  self.data = props.data or {} -- Expects a 2D array of strings
  self.width = props.width or 80
  self.header_hl = props.header_hl or "VoltTableHeader"

  self.col_widths = get_column_widths(self.data, self.width)

  return self
end

function M:_render_border(row_type)
  local str = ""
  for i, w in ipairs(self.col_widths) do
    local t_char = border_chars.mid[row_type or "none"]
    t_char = (i == #self.col_widths) and "" or t_char
    str = str .. string.rep("─", w + 2) .. t_char
  end

  local l_char = border_chars.corners_left[row_type or "none"]
  local r_char = border_chars.corners_right[row_type or "none"]

  return { { l_char .. str .. r_char, "VoltTableBorder" } }
end

function M:_render_row(row_data, hl)
  local line = { { "│", "VoltTableBorder" } }
  for i, cell in ipairs(row_data) do
    local cell_text = type(cell) == "table" and cell[1] or tostring(cell)
    local cell_hl = (type(cell) == "table" and cell[2]) or hl or "Normal"

    local content_width = self.col_widths[i]
    local text_width = vim.fn.strwidth(cell_text)
    local padding = content_width - text_width
    local l_pad = string.rep(" ", math.floor(padding / 2))
    local r_pad = string.rep(" ", math.ceil(padding / 2))

    table.insert(line, { " " .. l_pad .. cell_text .. r_pad .. " ", cell_hl })
    table.insert(line, { "│", "VoltTableBorder" })
  end
  return line
end

function M:render()
  local lines = {}

  if self.title then
    table.insert(lines, { { self.title, "Title" } })
  end

  if #self.data == 0 then
    return lines
  end

  table.insert(lines, self:_render_border("top"))

  -- Header
  table.insert(lines, self:_render_row(self.data[1], self.header_hl))

  -- Body
  for i = 2, #self.data do
    table.insert(lines, self:_render_border("none"))
    table.insert(lines, self:_render_row(self.data[i]))
  end

  table.insert(lines, self:_render_border("bot"))

  return lines
end

return M
