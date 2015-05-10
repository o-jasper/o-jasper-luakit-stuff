
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

local Public = {}

local function open_asset(path, search_in)
   search_in = search_in or search_dirs
   for _, dir in pairs(search_in) do
      local got = io.open(dir .. path, "r")
      if got then
         return got, dir
      end
   end
end

-- Search all the assets, and load it if exists.
function Public.load_asset(path, dont_memorize)
   if not dont_memorize and memorize_data[path] then
      return memorize_data[path]
   end
   local got, _ = open_asset(path)
   if got then
      local ret = got:read("*a")
      if not dont_memorize then
         memorize_data[path] = ret
      end
      got:close()
      return ret
   end
end

-- Search assets, return directory if exists.
function Public.asset_dir(path)
   local got, dir = open_asset(path)
   if got then
      got:close()
      return dir
   end
end

function Public.load_search_asset(where, path, dont_memorize)
   if type(where) ~= "table" then where = {where} end
   for _, where_path in pairs(where) do
      local splitpath = string_split(where_path, "/")
      while #splitpath > 0 do
         local got = Public.load_asset(table.concat(splitpath, "/") .. "/" .. path,
                                       dont_memorize)
         if got then return got end
         table.remove(splitpath)
      end
   end
end

function Public.search_asset_dir(where, path)
   if type(where) ~= "table" then where = {where} end
   for _, where_path in pairs(where) do
      local got = Public.asset_dir(where_path ..path)
      if got then return got end
   end
end

return Public
