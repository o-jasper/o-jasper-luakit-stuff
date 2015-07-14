local package_path = require("package").path
local string_split = require "o_jasper_common.string_split"

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

local function read_and_close(fd, path, dont_memorize)
   local ret = fd:read("*a")
   if not dont_memorize then
      memorize_data[path] = ret
   end
   fd:close()
   return ret
end

-- Search all the assets, and load it if exists.
function Public.load_asset(path, dont_memorize)
   if not dont_memorize and memorize_data[path] then
      return memorize_data[path]
   end
   local got, _ = open_asset(path)
   if got then return read_and_close(got, path, dont_memorize) end
end

-- Search asset, return opened if exists.
function Public.open_search_asset(where, path)
   if type(where) ~= "table" then where = {where} end
   for _, where_path in pairs(where) do
      -- * Indicates to search parents afterwards.
      if string.match(where_path, "[*].+") then
         local splitpath = string_split(string.sub(where_path, 2), "/")
         while #splitpath > 0 do
            local cur_path = table.concat(splitpath, "/") .. "/" .. path
            local got, _ = open_asset(cur_path)
            if got then
               return got, cur_path
            end
            table.remove(splitpath)
         end
      else
         local got, _ = open_asset(where_path ..path)
         if got then
            return got, where_path ..path
         end
      end
   end
end

function Public.search_asset(where, path)
   local got, at_path = Public.open_search_asset(where, path)
   if got then
      got:close()
      return at_path
   end   
end

function Public.load_search_asset(where, path, dont_memorize)
   local got, at_path = Public.open_search_asset(where, path)
   if got then return read_and_close(got, at_path, dont_memorize) end
end

return Public
