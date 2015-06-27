--  Copyright (C) 11-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- TODO also export? Or have the same format as the old bookmarks and have
-- data_uri external?

local string_split = require("lousy").util.string.split

return function(from_db, into)
   local n, m = 0, 32
   
   local from_collect  = from_db:compile("SELECT * FROM bookmarks LIMIT ?, ?")
   local to_uri_search = into.db:compile("SELECT id FROM bookmarks WHERE to_uri == ?")

   local got = from_collect:exec({n,m})
   while #got > 0 do  -- Not all of them at the same time.
      for _, el in pairs(got) do
         if #(to_uri_search:exec({el.uri})) == 0 then
            into:enter({ to_uri = el.uri or "", title = el.title or "", desc = el.desc or "",
                         created = el.created or os.time(),
                         data_uri = "",
                         tags = el.tags and string_split(el.tags) or {},
                       })
         end
      end
      n = n + m
      got = from_collect:exec({n,m})
   end
end
