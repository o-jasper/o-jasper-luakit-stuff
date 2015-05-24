--  Copyright (C) 25-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local cur_time = require "o_jasper_common.cur_time"
local Public = {}

Public._status = {}
function Public.status(domain)
   local got = Public._status[domain]
   if not got then
      got = {}
      Public._status[domain] = got
   end
   return got      
end

local last_cleanup, cleanup_interval = 0, 1000
function Public.cleanup()
   last_cleanup = cur_time.ms()
   -- NOTE: no cleanup yet.
end

function Public.now(domain, status)
   local got = Public.status(domain)
   got.status = status
   got.times = got.times or {}
   got.times[status] = cur_time.ms()

   if cur_time.ms() - last_cleanup > cleanup_interval then
      Public.cleanup()
   end
end

return Public
