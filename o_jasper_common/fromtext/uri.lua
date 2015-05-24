-- This should be in lib/lousy/uri.lua ?
return {
   domain_of_uri = function(uri)
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
}
