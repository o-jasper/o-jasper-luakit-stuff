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

-- Whole integer to string.
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

-- Just get the gist of the number. (three numbers)
function Public.int_gist(x)
   local pow = math.floor(math.log(x, 10)/3)
   local name = ({"n", "u", "m", "", "k", "M", "G", "T"})[pow + 4]
   if name then
      local t = math.floor(x / 1000^pow)
      if t < 10 then
         return string.format("%d.%d%s", t, math.floor(10*x / 1000^pow)%10, name)
      else
         return string.format("%d%s", t, name)
      end
   else
      return Public.int_w_numcnt(x)
   end
end

function Public.int_w_numcnt(x, sub)
   sub = sub or 2
   local pow = math.floor(math.log(x, 10)) - sub
   return string.format("%dE%d", math.floor(x/10^pow + 0.5), pow)
end

return Public
