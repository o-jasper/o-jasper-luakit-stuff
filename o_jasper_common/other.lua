-- Jasper den Ouden, placed in public domain.

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
