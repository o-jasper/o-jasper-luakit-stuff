-- This should be in lib/lousy/uri.lua ?
function domain_of_uri(uri)
   if string.match(uri, "^file://.+") then
      return "file://"
   else
      local _, s = string.find(uri, "//")
      if s then
         local e, _ = string.find(uri, "/", s+1)
         e = e or #uri + 1
         return string.sub(uri, s + 1, e - 1)
      else
         return "unknown"
      end
   end
end

function ensure_table(x) 
   if not x then return {} end
   if type(x) == "table" then return x else return {x} end 
end
function ensure_pairs(x) 
   if type(x) =="function" then return x else return pairs(ensure_table(x)) end
end
