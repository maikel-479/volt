-- lua/volt/compat/devicons.lua
-- Backwards compatibility shim that mimics parts of the nvim-web-devicons API
-- Now forwards opts = { os, de, wm } where applicable.

local icons = require "volt.icons"

local M = {}

-- Mimic nvim-web-devicons.get_icon(filename, extension, opts)
-- Original callers often pass (filename, extension, opts); accept and forward opts.
function M.get_icon(name, ext, opts)
  local icon, color, hl_name = icons.get_icon(name, ext, opts)
  local hl = "VoltIcon" .. (hl_name or "Default")
  return icon, hl
end

-- Minimal get_icon_color(filename, extension, opts)
function M.get_icon_color(name, ext, opts)
  local _, color = icons.get_icon(name, ext, opts)
  return color
end

-- Provide a filetype-based helper (best-effort)
function M.get_icon_by_filetype(ft, opts)
  return M.get_icon(ft, ft, opts)
end

function M.setup(opts)
  -- noop: Volt manages icons internally
end

return M
