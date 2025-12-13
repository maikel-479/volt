-- lua/volt/icons.lua
-- Minimal, cache-friendly icon provider with optional lazy full-set loader
-- Extended to support environment maps: by_operating_system, by_desktop_environment, by_window_manager

local M = {}

-- Icon cache for performance
local icon_cache = {}

-- Lightweight icon data (commonly used)
local icons_by_extension = {
  -- Programming Languages
  lua   = { icon = "", color = "#51A0CF", name = "Lua" },
  js    = { icon = "", color = "#CBCB41", name = "JavaScript" },
  ts    = { icon = "", color = "#519ABA", name = "TypeScript" },
  jsx   = { icon = "", color = "#20C2E3", name = "JavaScriptReact" },
  tsx   = { icon = "", color = "#519ABA", name = "TypeScriptReact" },
  py    = { icon = "", color = "#3572A5", name = "Python" },
  rs    = { icon = "", color = "#DEA584", name = "Rust" },
  go    = { icon = "", color = "#00ADD8", name = "Go" },
  c     = { icon = "", color = "#599EFF", name = "C" },
  cpp   = { icon = "", color = "#519ABA", name = "Cpp" },
  h     = { icon = "", color = "#A074C4", name = "H" },
  hpp   = { icon = "", color = "#A074C4", name = "Hpp" },
  java  = { icon = "", color = "#CC3E44", name = "Java" },
  rb    = { icon = "", color = "#701516", name = "Ruby" },
  php   = { icon = "", color = "#A074C4", name = "Php" },
  vim   = { icon = "", color = "#019833", name = "Vim" },

  -- Markup & Data
  html  = { icon = "", color = "#E44D26", name = "Html" },
  css   = { icon = "", color = "#663399", name = "Css" },
  scss  = { icon = "", color = "#F55385", name = "Scss" },
  sass  = { icon = "", color = "#F55385", name = "Sass" },
  json  = { icon = "", color = "#CBCB41", name = "JSON" },
  yaml  = { icon = "", color = "#6D8086", name = "Yaml" },
  yml   = { icon = "", color = "#6D8086", name = "Yml" },
  toml  = { icon = "", color = "#9C4221", name = "TOML" },
  xml   = { icon = "", color = "#E37933", name = "Xml" },
  md    = { icon = "", color = "#519ABA", name = "Markdown" },

  -- Shell & Config
  sh    = { icon = "", color = "#4D5A5E", name = "Shell" },
  bash  = { icon = "", color = "#89E051", name = "Bash" },
  zsh   = { icon = "", color = "#F15BB5", name = "Zsh" },
  fish  = { icon = "󰈺", color = "#4DB6AC", name = "Fish" },
  conf  = { icon = "", color = "#6D8086", name = "Conf" },
  env   = { icon = "", color = "#FAF743", name = "Env" },

  -- Database
  sql   = { icon = "", color = "#DAD8D8", name = "Sql" },
  db    = { icon = "", color = "#DAD8D8", name = "Db" },

  -- Images
  png   = { icon = "", color = "#A074C4", name = "Png" },
  jpg   = { icon = "", color = "#A074C4", name = "Jpg" },
  jpeg  = { icon = "", color = "#A074C4", name = "Jpeg" },
  gif   = { icon = "", color = "#A074C4", name = "Gif" },
  svg   = { icon = "󰜡", color = "#FFB13B", name = "Svg" },
  ico   = { icon = "", color = "#CBCB41", name = "Ico" },

  -- Archives
  zip   = { icon = "", color = "#ECA517", name = "Zip" },
  tar   = { icon = "", color = "#ECA517", name = "Tar" },
  gz    = { icon = "", color = "#ECA517", name = "Gz" },
  rar   = { icon = "", color = "#ECA517", name = "Rar" },
  ["7z"]= { icon = "", color = "#ECA517", name = "7z" },

  -- Documents
  pdf   = { icon = "", color = "#B30B00", name = "Pdf" },
  doc   = { icon = "󰈬", color = "#185ABD", name = "Doc" },
  docx  = { icon = "󰈬", color = "#185ABD", name = "Docx" },
  txt   = { icon = "", color = "#89E051", name = "Text" },
},

local icons_by_filename = {
  -- Git
  [".gitignore"]      = { icon = "", color = "#F54D27", name = "GitIgnore" },
  [".gitattributes"]  = { icon = "", color = "#F54D27", name = "GitAttributes" },
  [".gitconfig"]      = { icon = "", color = "#F54D27", name = "GitConfig" },
  [".gitmodules"]     = { icon = "", color = "#F54D27", name = "GitModules" },

  -- Docker
  ["dockerfile"]         = { icon = "󰡨", color = "#458EE6", name = "Dockerfile" },
  [".dockerignore"]     = { icon = "󰡨", color = "#458EE6", name = "DockerIgnore" },
  ["docker-compose.yml"]= { icon = "󰡨", color = "#458EE6", name = "DockerCompose" },

  -- Package Managers
  ["package.json"]       = { icon = "", color = "#E8274B", name = "PackageJson" },
  ["package-lock.json"]  = { icon = "", color = "#7A0D21", name = "PackageLockJson" },
  ["yarn.lock"]          = { icon = "", color = "#2C8EBB", name = "YarnLock" },
  ["pnpm-lock.yaml"]     = { icon = "", color = "#F9AD02", name = "PNPMLock" },
  ["cargo.toml"]         = { icon = "", color = "#DEA584", name = "Cargo" },
  ["go.mod"]             = { icon = "", color = "#00ADD8", name = "GoMod" },
  ["pyproject.toml"]     = { icon = "", color = "#3572A5", name = "PyProject" },
  ["requirements.txt"]   = { icon = "", color = "#3572A5", name = "Requirements" },

  -- Config Files
  ["tsconfig.json"]      = { icon = "", color = "#519ABA", name = "TSConfig" },
  ["webpack.config.js"]  = { icon = "󰜫", color = "#519ABA", name = "Webpack" },
  ["vite.config.js"]     = { icon = "", color = "#FFA800", name = "ViteConfig" },
  [".eslintrc"]          = { icon = "󰱺", color = "#4B32C3", name = "Eslintrc" },
  [".prettierrc"]        = { icon = "󰱺", color = "#4285F4", name = "PrettierConfig" },
  [".editorconfig"]      = { icon = "", color = "#FFF2F2", name = "EditorConfig" },

  -- Build Tools
  ["makefile"]           = { icon = "", color = "#6D8086", name = "Makefile" },
  ["cmakelists.txt"]     = { icon = "", color = "#DCE3EB", name = "CMakeLists" },
  ["justfile"]           = { icon = "", color = "#6D8086", name = "Justfile" },

  -- Shell Config
  [".bashrc"]            = { icon = "", color = "#89E051", name = "Bashrc" },
  [".zshrc"]             = { icon = "", color = "#89E051", name = "Zshrc" },
  [".bash_profile"]      = { icon = "", color = "#89E051", name = "BashProfile" },

  -- Editor Config
  [".vimrc"]             = { icon = "", color = "#019833", name = "Vimrc" },
  ["init.lua"]           = { icon = "", color = "#51A0CF", name = "LuaInit" },
  ["init.vim"]           = { icon = "", color = "#019833", name = "VimInit" },

  -- Env & Secrets
  [".env"]               = { icon = "", color = "#FAF743", name = "Env" },
  [".env.local"]         = { icon = "", color = "#FAF743", name = "Env" },
  [".env.example"]       = { icon = "", color = "#FAF743", name = "Env" },

  -- Documentation
  ["readme.md"]          = { icon = "󰂺", color = "#EDEDED", name = "Readme" },
  ["readme"]             = { icon = "󰂺", color = "#EDEDED", name = "Readme" },
  ["license"]            = { icon = "󰿃", color = "#D0BF41", name = "License" },
  ["license.md"]         = { icon = "󰿃", color = "#D0BF41", name = "License" },
  ["changelog.md"]       = { icon = "", color = "#EDEDED", name = "Changelog" },
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
