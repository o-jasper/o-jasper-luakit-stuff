--  Copyright (C) 27-03-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local Dir = require "dirChrome.Dir"
local lfs = require "lfs"

local config = globals.dirChrome or {}

local db = config.db or sqlite3{filename=":memory:"}

db:exec [[
   CREATE TABLE IF NOT EXISTS files (
     id INTEGER PRIMARY KEY,
  
     dir TEXT NOT NULL,
     file TEXT NOT NULL,
     mode TEXT NOT NULL,

     size INTEGER NOT NULL,  
     time_access INTEGER NOT NULL,
     time_modified INTEGER NOT NULL
   );
]]
   
return function(path)
    -- TODO ... what did lua use again?
   return setmetatable({ db = db, 
                         path=lfs.attributes(path) and path or "/home/"  },
      Dir)
end
