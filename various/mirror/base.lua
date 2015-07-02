local This = {}

function This:conf()       return globals.mirror or {} end
function This:mirror_dir()
   return self:conf().mirror_dir or (os.getenv("HOME") .. "/.luakit/mirror/")
end

function This:path(uri)
   if string.match(uri, "^http://") then uri = string.sub(uri, 8) end
   if string.match(uri, "^https://") then uri = string.sub(uri, 9) end
   return self:mirror_dir() .. uri
end

function This:page_path(uri)
   local path = self:path(uri)
   local endm = string.match(path, "#[^/]+$")
   if string.match(path, "/$") then
      path = path .. "index.html"
   elseif endm then
      path = string.sub(path, 1, #path - #endm)
   end
   return path
end

local string_split = require("lousy").util.string.split
local function basename(path)
   local list = string_split(path, "/")
   table.remove(list)  -- Remove last one.
   return table.concat(list, "/")
end

function This:clear_path(path)
   luakit.spawn_sync("mkdir -p " .. basename(path))
   return path
end

function This:mirror_uri(uri)
   return "file://" ..  self:path(uri)
end

return This
