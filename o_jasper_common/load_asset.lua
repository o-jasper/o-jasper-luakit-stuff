-- Get luakit environment
local package = require("package")
local lousy = require("lousy")
local capi = { luakit = luakit }

local search_dirs = {} -- Directories where assets may be.

for _, el in pairs(lousy.util.string.split(package.path, ";")) do
   if string.sub(el, -6) == "/?.lua" then
      table.insert(search_dirs, string.sub(el, 1,-6))
   end
end

local memorize_data = {}  -- Keeps track of what we already got.

-- Search all the assets, and load it if exists.
function load_asset(path, memorize)
   if memorize and memorize_data[path] then
      return memorize_data[path]
   end
   for _, dir in pairs(search_dirs) do
      local got = io.open(dir .. path, "r")
      if got then
         local ret = got:read("*a")
         if memorize then
            memorize_data[path] = ret
         end
         got:close()
         return ret
      end
   end
   return nil
end