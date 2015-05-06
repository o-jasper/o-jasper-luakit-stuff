-- Get luakit environment
local package_path = require("package").path
local string_split = require("lousy").util.string.split
local capi = { luakit = luakit }

local search_dirs = {} -- Directories where assets may be.

for _, el in pairs(string_split(package_path, ";")) do
   if string.sub(el, -6) == "/?.lua" then
      table.insert(search_dirs, string.sub(el, 1,-6))
   end
end

local memorize_data = {}  -- Keeps track of what we already got.

-- TODO should also have `get_asset_path`

-- Search all the assets, and load it if exists.
local function load_asset(path, dont_memorize)
   if not dont_memorize and memorize_data[path] then
      return memorize_data[path]
   end
   for _, dir in pairs(search_dirs) do
      local got = io.open(dir .. path, "r")
      if got then
         local ret = got:read("*a")
         if not dont_memorize then
            memorize_data[path] = ret
         end
         got:close()
         return ret
      end
   end
   return nil
end

return load_asset
