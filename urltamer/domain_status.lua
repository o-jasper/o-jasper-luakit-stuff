--  Copyright (C) 25-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

_domain_status = {}
function domain_status(domain)
   local got = _domain_status[domain]
   if not got then
      got = {}
      _domain_status[domain] = got
   end
   return got      
end

local last_cleanup, cleanup_interval = 0, 1000
function cleanup_status()
   last_cleanup = gettime()
   -- NOTE: no cleanup yet.
end

function status_now(domain, status)
   local got = domain_status(domain)
   got.status = status
   got.times = got.times or {}
   got.times[status] = gettime()

   if gettime() - last_cleanup > cleanup_interval then
      cleanup_status()
   end
end
