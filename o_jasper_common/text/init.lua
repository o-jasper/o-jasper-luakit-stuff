local Public = {}

function tableText(herp, tab, first, ln)
   local ret = {}
   for k,v in pairs(herp) do
      if type(v) == "table" then
         table.insert(ret, first .. tostring(k))
         table.insert(ret, tableText(v, tab, first .. tab))
      else
         table.insert(ret, first .. tostring(k) .. ":" .. tostring(v))
      end
   end
   return table.concat(ret, ln)
end

function Public.tableText(herp, tab, first, ln)
   return tableText(herp, tab or "  ", first or "", ln or "\n")
end

function Public.int_to_string(i)
   local largenum = 10000000000000
   if math.floor(i/largenum) == 0 then
      return tostring(i)
   else
      local str = tostring(i%largenum)
      while #str ~= 13 do  -- TODO is it right.. didnt i solve this before..?
         str = "0" .. str
      end
      return tostring(math.floor(i/largenum)) .. str
   end
end

return Public
