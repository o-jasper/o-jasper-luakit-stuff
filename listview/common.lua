--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "socket"

function cur_time() return socket.gettime() end
function cur_time_ms() return math.floor(1000*socket.gettime()) end
function cur_time_s()  return math.floor(socket.gettime()) end

-- But one way to use metatables.
function metatable_for(meta)
   meta.direct         = meta.direct or {}
   meta.determine      = meta.determine or {}
   
   meta.table = {__index = function(self, key)
      local got = rawget(self, key) or meta.direct[key]
      -- Return value, because set, or because specified by metatable.c
      if got or type(got) == "boolean" then
         return got(self, key)
      else
         local determiner = meta.determine[key]
         if determiner then  -- To be determined by functions.
            local val = determiner(self, key)
            rawset(self,key, val)
            return val
         end
         error(string.format("... No way to get the index? %q", key))
      end
   end}
   return meta
end

function isinteger(x) return type(x) == "number" and math.floor(x) == x end

function map(list, fun)
   local ret = {}
   for _, v in pairs(list) do table.insert(ret, fun(v)) end
   return ret
end

function map_kv(list, fun)
   local ret = {}
   for k, v in pairs(list) do ret[k] = fun(k,v) end
   return ret
end

function map_l_kv(list, fun)
   local ret = {}
   for k, v in pairs(list) do table.insert(ret, fun(k,v)) end
   return ret
end

function full_gsub(str, subst)  -- Perhaps something for lousy.util.string
   local n, k = 1, 0
   while n > 0 and k < 64 do
      str, n = string.gsub(str, "{%%(%w+)}", subst)
      if k%4 == 0 then  -- For some reason n does not tick to zero, check for matches.
         local any = false
         for k,_ in pairs(subst) do 
            if string.find(str, "{%%" .. k .. "}") then any = true end
         end
         if not any then return str end
      end
      k = k + 1
   end
   return str
end
