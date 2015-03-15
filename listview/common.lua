--  Copyright (C) 14-03-2015 Jasper den Ouden.
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
function metatable_of(meta)
   -- Ensure there is something in there.
   meta.defaults  = meta.defaults or {}
   meta.direct    = meta.direct or {}
   meta.determine = meta.determine or {}
   meta.values    = meta.values or {}

   meta.defaults.values = meta.values
   
   if not meta.metatable then
      meta.metatable = {
         __index = function(self, key)
            local got = meta.defaults[key]
            if got ~= nil then return got end
            
            local got = meta.direct[key]
            if got then return got(self, key) end
            
            local determiner = meta.determine[key]
            if determiner then  -- To be determined by functions.
            local val = determiner(self, key)
            rawset(self,key, val)
            return val
            end
            if meta.otherwise then
               return meta.otherwise(self, key)
            else
               error(string.format("... No way to get the index? %q", key))
            end
         end,
         meta=meta
      }
   end
   return meta.metatable
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

function copy_table_1(tab)  -- One-deep copy of table.
   local ret = {}
   for k,v in pairs(tab) do ret[k] = v end
   return ret
end

function copy_table(tab)  -- One-deep copy of table.
   local ret = {}
   for k,v in pairs(tab) do
      if type(v) == "table" then
         ret[k] = copy_table(v)
      else
         ret[k] = v
      end
   end
   return ret
end

function values_now_set(tab)
   local ret = {}
   for _,v in pairs(tab) do ret[v] = true end
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
