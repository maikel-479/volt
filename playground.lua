-- playground.lua
--
-- A "storybook" style environment for developing and testing Volt components.
--
-- To run:
--   :luafile playground.lua
--
-- To close:
--   Press 'q' in the playground window.

local volt = require("volt")
local api = vim.api

-- Component Imports
local Button = require("volt.ui.components.button")
local LinearLayout = require("volt.ui.components.layout")
local Slider = require("volt.ui.components.slider")
local Table = require("volt.ui.components.table")
local Tabs = require("volt.ui.components.tabs")

-- 1. Create a buffer for our playground
local buf = api.nvim_create_buf(false, true)
api.nvim_buf_set_option(buf, "bufhidden", "wipe")

-- We need a way to re-render the components that display state.
-- For the playground, we can just redraw the whole UI.
local function redraw_playground()
  vim.schedule(function()
    volt.redraw(buf, "all")
  end)
end

-- 2. Create instances of our new components
local counter = 0
local counter_text = "Click count: 0"

local button1 = Button.new({
  text = "Click Me!",
  on_click = function()
    counter = counter + 1
    counter_text = "Click count: " .. tostring(counter)
    redraw_playground()
  end,
})

local slider1 = Slider.new({
  text = "Volume",
  width = 30,
  value = 75,
  on_change = function(new_value)
    print("Slider value changed to: " .. new_value)
    redraw_playground() -- Redraw to reflect the new value
  end,
})

local table1 = Table.new({
  title = "My Awesome Data",
  width = 60,
  data = {
    { "Name", "Age", "Occupation" },
    { "Jules", "30", "Software Engineer" },
    { "Bob", "42", "Plumber" },
  },
})

local tabs1 = Tabs.new({
  tabs = { "Tab 1", "Tab 2", "Another Tab" },
  active_tab = 2,
  on_tab_change = function(i, name)
    print("Tab changed to: " .. name .. " (index " .. i .. ")")
    redraw_playground()
  end,
})

-- 3. Define the layout for the playground window
local playground_layout = {
  {
    name = "header",
    lines = function(buf)
      return {
        { { "--- Volt Component Playground ---", "Title" } },
        { { "", "Normal" } },
      }
    end,
  },
  {
    name = "tabs_test",
    lines = function(buf)
      local rendered_tabs = tabs1:render()
      return {
        { { "Tabs Component:", "Comment" } },
        unpack(rendered_tabs),
        { { "", "Normal" } },
      }
    end,
  },
  {
    name = "slider_test",
    lines = function(buf)
      return {
        { { "Slider Component:", "Comment" } },
        unpack(slider1:render()),
        { { "", "Normal" } },
      }
    end,
  },
  {
    name = "table_test",
    lines = function(buf)
      local rendered_table = table1:render()
      return {
        { { "Table Component:", "Comment" } },
        unpack(rendered_table),
        { { "", "Normal" } },
      }
    end,
  },
  {
    name = "button_test",
    lines = function(buf)
      return {
        { { "Button Component:", "Comment" } },
        unpack(button1:render()),
        { { counter_text, "String" } },
      }
    end,
  },
}

-- 4. Prepare the data for Volt
local ui_data = {
  {
    buf = buf,
    ns = api.nvim_create_namespace("volt_playground"),
    layout = playground_layout,
    xpad = 2,
  },
}

volt.gen_data(ui_data)

-- 5. Define the UI instance configuration
local ui_instance = {
  bufs = { buf },
  winclosed_event = true,
}

volt.mappings(ui_instance)

-- 6. Function to open the playground window
local function open_playground()
  local win_height = 30
  local win_width = 80

  local win = api.nvim_open_win(buf, true, {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = math.floor((vim.o.lines - win_height) / 2),
    col = math.floor((vim.o.columns - win_width) / 2),
    style = "minimal",
    border = "single",
  })

  vim.api.nvim_win_set_option(win, "cursorline", false)

  volt.run(buf, { h = win_height, w = win_width })
end

-- Open it!
open_playground()

print("Volt Playground is open. Press 'q' to close.")
