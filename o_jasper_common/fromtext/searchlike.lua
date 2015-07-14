
local string_split = require "o_jasper_common.string_split"

local Public = {}

-- Splits things up by whitespace and quotes.
function Public.portions(str)
   local list = {}
   for i, el in pairs(string_split(str, "\"")) do
      if i%2 == 1 then
         for _, sel in pairs(string_split(el, " ")) do table.insert(list, sel) end
      else
         table.insert(list, el)
      end
   end
   return list
end

-- Finds commands in the search (TODO name is confusing)
function Public.searchlike(portions, matchable)
   local ret, dibs = {}, false
   for _, el in pairs(portions) do
      local done = false
      for _, m in pairs(matchable) do
         if string.sub(el, 1, #m) == m then -- Match.
            if #el == #m then
               dibs = m  -- All of them, keep.
               done = true
               break
            else
               table.insert(ret, {m=m, v=string.sub(el, #m + 1)})
               done = true
               break
            end
         end
      end
      if not done then
         if dibs then -- Previous matched, get it.
            table.insert(ret, {m=m, v=el})
            dibs = nil
         else 
            table.insert(ret, {v=el})
         end
      end
   end
   return ret
end

return Public
