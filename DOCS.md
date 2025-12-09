# Volt Framework Documentation

This document provides an overview of the Volt framework, details on recent enhancements, and a guide for developers looking to use it to build interactive UIs in Neovim.

## 1. What is Volt?

Volt is a powerful Lua-based framework for Neovim that enables developers to create rich, interactive, and beautiful user interfaces directly within the editor. It provides a set of tools and conventions for managing UI state, handling user input (mouse and keyboard), and drawing complex layouts with clickable and hoverable elements. It is designed to be the engine behind sophisticated plugins that require more than the standard Neovim API offers.

## 2. Recent Enhancements

The Volt framework has undergone a significant refactoring to improve its stability, performance, and maintainability. These changes are crucial for a framework designed to run for the entire duration of a Neovim session.

### Key Improvements:

*   **Robust UI Cleanup Logic:**
    *   **Problem:** Closing a Volt-based UI could leave visual artifacts (like background overlays or floating windows) on the screen.
    *   **Solution:** The closing logic was rewritten to be more robust. It now explicitly finds and closes all Neovim windows associated with a UI instance before deleting the underlying buffers. This ensures a clean and complete shutdown of all UI elements every time.

*   **Encapsulated State Management:**
    *   **Problem:** The UI state was previously managed in a global table, making it vulnerable to conflicts and difficult to maintain.
    *   **Solution:** State management is now encapsulated within a dedicated module. All state is managed through `state.create()`, `state.get()`, and `state.remove()` functions, ensuring that each UI instance has its own isolated state and preventing unintended side effects.

*   **Fix for Global State Leaks:**
    *   **Problem:** The buffer cycling feature used a global index variable, causing state conflicts when multiple Volt UIs were open simultaneously.
    *   **Solution:** The buffer index is now stored on the individual UI instance object, ensuring that the state for each UI is kept separate and correct.

*   **Performance Optimization:**
    *   **Problem:** Looking up UI sections required iterating through a list, which could be slow for complex UIs.
    *   **Solution:** The layout data structure was changed from a list to a map (or dictionary), allowing for near-instantaneous lookups of UI sections. This improves rendering performance.

*   **Improved Modularity:**
    *   **Problem:** Modules were too tightly coupled, with some modules directly manipulating the internal data of others.
    *   **Solution:** The interaction between modules has been cleaned up. For example, the `utils` module now uses a dedicated `events.remove()` function instead of directly modifying the `events` module's internal buffer list.

### Why These Changes Matter:

*   **Stability:** By eliminating global state and ensuring complete UI cleanup, the framework is now significantly more stable and reliable, which is critical for a long-running application like Neovim.
*   **Maintainability:** The codebase is now cleaner, more modular, and easier to understand, making it simpler for developers to build on top of Volt and contribute to its development.
*   **Performance:** The optimized section lookup makes the UI feel snappier, especially for complex layouts.

## 3. Developer's Guide: How to Use Volt

Volt is designed to be straightforward. Here are the core concepts and a simple example to get you started.

### Core Concepts

1.  **Layout Definition:** A UI is defined by a `layout`. The layout is a table of "sections," where each section has a name and a `lines` function. The `lines` function is responsible for generating the text and highlight groups for that part of the UI.
2.  **State Management:** Each UI you create gets its own isolated state table. This is where you can store any data your UI needs to maintain, such as the current selection, a list of items, etc.
3.  **Running the UI:** You initialize the UI by creating a buffer and then calling the main `volt.run()` function, which handles drawing, setting up event listeners, and making the UI interactive.

### Example: Creating a Simple Interactive Menu

Here is a basic example of how you might create a simple menu with a clickable item.

```lua
local volt = require("volt")
local api = vim.api

-- 1. Create a buffer for our UI
local buf = api.nvim_create_buf(false, true)
api.nvim_buf_set_option(buf, "bufhidden", "wipe")

-- 2. Define the layout for the menu
local my_layout = {
  {
    name = "header",
    lines = function(buf)
      return {
        { { "--- My Cool Menu ---", "Title" } },
      }
    end,
  },
  {
    name = "body",
    lines = function(buf)
      return {
        { { "Click me!", "Comment", function()
          print("You clicked me!")
          volt.close(buf) -- Close the UI after clicking
        end } },
        { { "Another item (not clickable)", "String" } },
      }
    end,
  },
}

-- 3. Prepare the data for Volt
local ui_data = {
  {
    buf = buf,
    ns = api.nvim_create_namespace("my_ui"),
    layout = my_layout,
    xpad = 2, -- Add some padding on the left
  },
}

-- 4. Generate the initial state and data structures
volt.gen_data(ui_data)

-- 5. Define the UI instance configuration
local my_ui_instance = {
  bufs = { buf },
  winclosed_event = true, -- Auto-cleanup on window close
}

-- 6. Set up the key mappings (like 'q' to close)
volt.mappings(my_ui_instance)

-- 7. Run the UI!
-- This would typically be called from a function that also opens the window.
local function open_menu()
  -- Create a floating window (example)
  local win = api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 40,
    height = 5,
    row = 5,
    col = 10,
    style = "minimal",
    border = "single",
  })

  -- Tell Volt to draw everything
  volt.run(buf, { h = 10, w = 40 })
end

-- Call the function to open your menu
open_menu()
```

This example demonstrates how to define a layout with a clickable action, set up the necessary data, and launch the UI in a floating window. The recent refactoring ensures that when `volt.close(buf)` is called, the window and all associated resources will be cleaned up correctly.
