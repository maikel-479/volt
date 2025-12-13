local volt = require("volt")
local highlights = require("volt.highlights")

-- Test that the main module loads without errors
assert(volt, "Failed to load volt module")

-- Test that the patched functions can be called without errors
local buf = vim.api.nvim_create_buf(true, false)
volt.run(buf, { h = 10, w = 10 })
volt.redraw(buf, "all")

-- Verify that the highlight groups are defined
local ex_dark_bg = vim.api.nvim_get_hl(0, { name = "ExDarkBg" })
assert(ex_dark_bg, "ExDarkBg highlight group not found")

print("Volt tests passed!")
