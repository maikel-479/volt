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

-- 1. Create a buffer for our playground
local buf = api.nvim_create_buf(false, true)
api.nvim_buf_set_option(buf, "bufhidden", "wipe")

-- 2. Create instances of our new components
local counter = 0
local counter_text = "Click count: 0"

-- We need a way to re-render the component that displays the counter.
-- In a real app, this would be handled by a more sophisticated state management system.
-- For the playground, we can just redraw the whole UI.
local function redraw_playground()
  volt.redraw(buf, "all")
end

local button1 = Button.new({
  text = "Click Me!",
  on_click = function()
    counter = counter + 1
    counter_text = "Click count: " .. tostring(counter)
    -- This is a temporary hack for the playground. A real reactive system
    -- would handle this more elegantly.
    print("Button clicked! Counter is now: " .. counter)
    redraw_playground()
  end,
})

local button2 = Button.new({
  text = "Another Button",
  on_click = function()
    print("You clicked the second button!")
  end,
})

local button3 = Button.new({ text = "Button 3" })

-- 3. Create a layout to arrange the components
local vertical_layout = LinearLayout.new({
  orientation = "vertical",
  children = { button1, button2 },
})

local horizontal_layout = LinearLayout.new({
  orientation = "horizontal",
  children = { button1, button2, button3 },
})

-- 4. Define the layout for the playground window
local playground_layout = {
  {
    name = "header",
    lines = function(buf)
      return {
        { { "--- Volt Component Playground ---", "Title" } },
        { { "", "Normal" } }, -- Spacer
      }
    end,
  },
  {
    name = "vertical_test",
    lines = function(buf)
      return {
        { { "Vertical LinearLayout:", "Comment" } },
        unpack(vertical_layout:render()),
        { { "", "Normal" } }, -- Spacer
      }
    end,
  },
  {
    name = "horizontal_test",
    lines = function(buf)
      return {
        { { "Horizontal LinearLayout:", "Comment" } },
        unpack(horizontal_layout:render()),
        { { "", "Normal" } }, -- Spacer
      }
    end,
  },
  {
    name = "state_test",
    lines = function(buf)
      -- This part is a bit of a hack to show state changes.
      -- It re-renders the text directly. In a real component,
      -- the text would be part of the component's own render method.
      return {
        { { "State Change Test:", "Comment" } },
        { { counter_text, "String" } },
      }
    end,
  },
}

-- 5. Prepare the data for Volt
local ui_data = {
  {
    buf = buf,
    ns = api.nvim_create_namespace("volt_playground"),
    layout = playground_layout,
    xpad = 2,
  },
}

volt.gen_data(ui_data)

-- 6. Define the UI instance configuration
local ui_instance = {
  bufs = { buf },
  winclosed_event = true,
}

volt.mappings(ui_instance)

-- 7. Function to open the playground window
local function open_playground()
  local win_height = 20
  local win_width = 60

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
