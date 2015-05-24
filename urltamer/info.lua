--  Copyright (C) 25-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local domain_status = require "urltamer.domain_status"
local ensure = require "o_jasper_common.ensure"
local domain_of_uri = require("o_jasper_common.fromtext.uri").domain_of_uri
local cur_time = require "o_jasper_common.cur_time"

-- Values directly returned, for instance member functions.
local info_metaindex_direct = {
   own_domain = function(self)
      return self.from_domain == "no_vuri" or self.from_domain == self.domain
   end,

   uri_match = function(self, match)
      for i, el in ensure.pairs(match) do
         if string.match(self.uri, el) then 
            return i
         end
      end
   end,
}

-- Values that are determined and memoized. (though memoizing is not necessarily better)
local info_metaindex_determine = {
   tags = function(self, _) return "" end,
   domain = function(self, _) return domain_of_uri(self.uri or "no_uri") end,
   
   vuri = function(self, _) return self.v.uri end,
   from_domain = function(self, _) return domain_of_uri(self.vuri or "no_vuri") end,

   current_status = function(self, _)
      local got = domain_status._status[self.from_domain]
      if not got then
         got = {}
         assert(self.from_domain, string.format("aint got (%s)", self.from_domain))
         domain_status._status[self.from_domain] = got
      end
      return got
   end,
   status = function(self, _) return self.current_status.status end,

   -- TODO destructive.. probably dont want.
   from_time = function(self, _) 
      return (self.current_status.times or {})["userevent-uri"] or 0
   end, 
   dt = function(self, _) return self.time - self.from_time end,
}

local info_metatable = {__index=function(self, key)
   local got = rawget(self, key) or info_metaindex_direct[key]
  -- Return value, because set, or because specified by metatable.c
   if got or type(got) == "boolean" then
      return got
   else
      local determiner = info_metaindex_determine[key]
      if determiner then  -- To be determined by functions.
         local val = determiner(self, key)
         rawset(self,key, val)
         return val
      end
      return nil
   end
end,
   -- TODO setting indexes?
}

return { 
   new_info = function(v, uri)
      local info = {v=v, uri=uri, time=cur_time.ms()}
      setmetatable(info, info_metatable)
      return info
   end
}
