return function(attrs, str)
   local newstr, cur, _ = "", {}, {}, nil

   local function ins_tag(v, fr)
      local j = string.find(str, "<[%s]*" .. v.tagname .. "[%s]+", fr)
      if j then table.insert(cur, {j, v}) end
   end
   for _,v in pairs(attrs) do ins_tag(v, 1) end

   local prev_j, endj = 1
   while #cur > 0 do
      table.sort(cur, function(a,b) return a[1] < b[1] end)
      local j, v = unpack(cur[1])  -- Nearest one.
      newstr = newstr ..  string.sub(str, prev_j, j) .. v.tagname
      if j >= (endj or 1) then  -- If not, it was part of quoted.
         local nj = j
         endj = nil
         
         while true do
            local fi,ti = string.find(str, "[%s]*,?[%s]*[%w-_]+=[%s]*\"", nj)
            if not fi or fi > string.find(str, ">", nj) then break end
            local m = string.sub(str, fi,ti)
            
            local attr_name = string.match(m, "[%w-_]+")
            endj = string.find(str, "\"", nj + #m + 2)  -- Find end of that thing.
            local attr_val  = string.sub(str, ti + 1, endj - 1)
            local new_val = v:fun(attr_name, attr_val)
            print(v.tagname, attr_name, attr_val, fi, ti,endj, m)
            if new_val ~= false then  -- `false` means, remove the value alltogether
               newstr = newstr .. " " .. attr_name .. "=\"" .. (new_val or attr_val) .. "\""
            end
            nj = endj
         end
         newstr = newstr .. ">"
         _, endj = string.find(str, ">", endj or j, true)
         endj = endj + 1
         prev_j = endj
         print(endj)
      else
         endj = endj + 1
      end
      table.remove(cur, 1)
      ins_tag(v, endj) -- Find one further on the file(maybe)
   end
   if endj then newstr = newstr .. string.sub(str, endj) end

   return newstr
end
