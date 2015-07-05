local Public = {}

local function permissive(info, result)
   --print("permissive", info.uri, info.vuri)
   result.allow = true
end

Public["^$"] = permissive
Public["^luakit://.+"] = permissive

return Public
