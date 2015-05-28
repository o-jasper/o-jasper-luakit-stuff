--  Copyright (C) 27-03-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local Dir = require "dirChrome.Dir"
local lfs = require "lfs"

local config = globals.dirChrome or {}

return function dirlog_at(path)
   
   local db = config.db or sqlite3{filename=":memory:"}
   
   ret = setmetatable({ db = db }, Dir)

   for file, _ in lfs.dir(path) do
      local entry = lfs.attributes(path)
      entry.dirname = path
      entry.filename = file
      entry.time_access = entry.access
      entry.time_modified = entry.modified

      ret:enter_or_update(entry)
   end
   return ret
end
