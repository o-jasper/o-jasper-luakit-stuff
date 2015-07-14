local function string_split(str, split_by, simple)
   simple = simple == nil or simple
   split_by = split_by or " "
   local list = {}
   local f, t
   while true do
      pt = (t or 0) + 1
      f,t = string.find(str, split_by, pt, simple)
      if f then
         table.insert(list, string.sub(str, pt, f - 1))
      else
         table.insert(list, string.sub(str, pt))
         return list
      end
   end
end

return string_split
