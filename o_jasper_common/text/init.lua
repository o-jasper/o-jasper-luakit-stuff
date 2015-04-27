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

return Public
