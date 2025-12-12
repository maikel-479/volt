-- lua/volt/icons.lua
-- Minimal, cache-friendly icon provider with optional lazy full-set loader
-- Extended to support environment maps: by_operating_system, by_desktop_environment, by_window_manager

local M = {}

-- Icon cache for performance
local icon_cache = {}

-- Lightweight icon data (commonly used)
local icons_by_extension = {
  lua = { icon = "", color = "#51A0CF", name = "Lua" },
  js  = { icon = "", color = "#EAD41C", name = "JavaScript" },
  ts  = { icon = "", color = "#2b7489", name = "TypeScript" },
  py  = { icon = "", color = "#3572A5", name = "Python" },
  md  = { icon = "", color = "#083fa1", name = "Markdown" },
  rs  = { icon = "", color = "#dea584", name = "Rust" },
  go  = { icon = "", color = "#00ADD8", name = "Go" },
  toml= { icon = "", color = "#9c4221", name = "TOML" },
  json= { icon = "ﬥ", color = "#cbcb41", name = "JSON" },
  sh  = { icon = "", color = "#6e4a7e", name = "Shell" },
}

local icons_by_filename = {
  [".gitignore"] = { icon = "", color = "#F54D27", name = "GitIgnore" },
  ["makefile"]   = { icon = "", color = "#6D8086", name = "Makefile" },
  ["dockerfile"] = { icon = "", color = "#0db7ed", name = "Dockerfile" },
  ["readme.md"]  = { icon = "", color = "#083fa1", name = "Readme" },
  ["license"]    = { icon = "", color = "#6d8086", name = "License" },
  ["package.json"]= { icon = "", color = "#cbcb41", name = "Npm" },
  ["tsconfig.json"]= { icon = "", color = "#2b7489", name = "TSConfig" },
  ["cargo.toml"] = { icon = "", color = "#dea584", name = "Cargo" },
  [".env"]       = { icon = "", color = "#4f5d95", name = "Env" },
  ["init.lua"]   = { icon = "", color = "#51A0CF", name = "LuaInit" },
}

-- Default fallback icon
local default_icon = {
  icon = "",
  color = "#6d8086",
  name = "Default"
}

-- Optional environment maps (populated from full icons when loaded)
local icons_by_operating_system = nil
local icons_by_desktop_environment = nil
local icons_by_window_manager = nil

local function normalize(s)
  if not s then return "" end
  return tostring(s):lower()
end

-- Build cache key including opts
local function cache_key(name, ext, opts)
  opts = opts or {}
  return (name or "") .. ":" .. (ext or "") .. ":" .. normalize(opts.os) .. ":" .. normalize(opts.de) .. ":" .. normalize(opts.wm)
end

-- Main get_icon accepts optional opts = { os = "linux", de = "gnome", wm = "i3" }
function M.get_icon(name, ext, opts)
  opts = opts or {}
  local key = cache_key(name, ext, opts)
  if icon_cache[key] then
    return unpack(icon_cache[key])
  end

  local icon_data

  -- 1) filename match (case-insensitive)
  if name then
    local lname = normalize(name)
    icon_data = icons_by_filename[lname]
  end

  -- 2) extension match
  if not icon_data and ext and ext ~= "" then
    local lext = normalize(ext)
    icon_data = icons_by_extension[lext]
  end

  -- 3) environment-specific (opts)
  if not icon_data and opts.os and icons_by_operating_system then
    icon_data = icons_by_operating_system[normalize(opts.os)]
  end
  if not icon_data and opts.de and icons_by_desktop_environment then
    icon_data = icons_by_desktop_environment[normalize(opts.de)]
  end
  if not icon_data and opts.wm and icons_by_window_manager then
    icon_data = icons_by_window_manager[normalize(opts.wm)]
  end

  -- 4) fallback
  icon_data = icon_data or default_icon

  icon_cache[key] = { icon_data.icon, icon_data.color, icon_data.name }
  return icon_data.icon, icon_data.color, icon_data.name
end

-- Lazy loading for full icon set
function M.load_full_icons()
  if M.full_icons_loaded then return end

  local ok, full_icons = pcall(require, "volt.icons.full")
  if ok and full_icons then
    if full_icons.by_extension then
      icons_by_extension = vim.tbl_extend("force", icons_by_extension, full_icons.by_extension)
    end
    if full_icons.by_filename then
      -- ensure keys are lowercase for filename map
      local normalized = {}
      for k,v in pairs(full_icons.by_filename) do
        normalized[k:lower()] = v
      end
      icons_by_filename = vim.tbl_extend("force", icons_by_filename, normalized)
    end
    if full_icons.by_operating_system then
      icons_by_operating_system = vim.tbl_extend("force", icons_by_operating_system or {}, full_icons.by_operating_system)
    end
    if full_icons.by_desktop_environment then
      icons_by_desktop_environment = vim.tbl_extend("force", icons_by_desktop_environment or {}, full_icons.by_desktop_environment)
    end
    if full_icons.by_window_manager then
      icons_by_window_manager = vim.tbl_extend("force", icons_by_window_manager or {}, full_icons.by_window_manager)
    end
    -- clear cache so new icons are picked up
    icon_cache = {}
  end

  M.full_icons_loaded = true
end

-- Utility to get icon with highlight group
function M.get_icon_with_hl(name, ext, opts)
  local icon, color, hl_name = M.get_icon(name, ext, opts)
  if color then
    local safe_name = (hl_name or "Default"):gsub("%s+", "")
    local hl_group = "VoltIcon" .. safe_name
    pcall(vim.api.nvim_set_hl, 0, hl_group, { fg = color })
    return icon, hl_group
  end
  return icon, nil
end

-- Expose small helpers to query whether env maps are available
function M.has_env_maps()
  return (icons_by_operating_system ~= nil) or (icons_by_desktop_environment ~= nil) or (icons_by_window_manager ~= nil)
end

return M
