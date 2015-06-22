local c = require "o_jasper_common"

return function(where, key)
   if type(key) == "string" then
      return c.load_search_asset(where, "/assets/" .. key) or
         string.format([[alert("ASSET NOT FOUND %s");]], key)
   else
      return string.format([[alert("ASSET NOT VALID %s");]], key)
   end
end
