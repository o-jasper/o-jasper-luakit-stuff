local Public = {}

local function string_split(str, by)
   local by = by or " "
   local pi, i, j, ret = 1, nil, nil, {}
   while true do
      i, j = string.find(str, by, pi)
      if not i then
         table.insert(ret, string.sub(str, pi))
         return ret
      else
         table.insert(ret, string.sub(str, pi, i - 1))
         pi = j + 1
      end
   end
end

-- Wonder why lua doesnt expose something like this.
function Public.alt_findfile(str)
   for _,at in pairs(string_split(package.path, ";")) do
      local pos = string.gsub(str, "[.]", "/")
      local cur_file = string.gsub(at, "[?]", pos)
      local open = io.open(cur_file)
      if open then
         io.close(open) 
         return cur_file
      end
   end
end

Public.already_loaded = {}

function Public.alt_require_plain(meta)
   return function(str)
      local got = Public.already_loaded[str]
      if got then
         return got
      else
         local file = Public.alt_findfile(str)
         -- TODO for `file == nil`, what should the behavior be?
         return file and loadfile(file, nil, setmetatable({}, meta))()
      end   
   end
end

return Public
