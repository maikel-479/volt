local M = {}
local states = {}

M.create = function(buf)
  states[buf] = {}
  return states[buf]
end

M.get = function(buf)
  return states[buf]
end

M.remove = function(buf)
  states[buf] = nil
end

return M
