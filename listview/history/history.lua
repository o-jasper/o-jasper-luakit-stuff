--  Copyright (C) 27-03-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local ret

if not ret then
   local History = require "listview.history.History"
   local db = ((globals.listview or {}).history or {}).db or require "listview.acquire_db"
   ret = setmetatable({ db = db }, History)
end

return ret
