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
  
     dirname TEXT NOT NULL,
     filename TEXT NOT NULL,
     mode TEXT NOT NULL,

     size INTEGER NOT NULL,  
     time_access INTEGER NOT NULL,
     time_modified INTEGER NOT NULL
   );
]]
   
return function(path)
   
   local ret = setmetatable({ db = db }, Dir)

   if not lfs.attributes(path) then
      path = "/home"  -- TODO
   end

   for file, _ in lfs.dir(path) do
      local entry = lfs.attributes(path)
      entry.dirname = path
      entry.filename = file
      entry.time_access = entry.access
      entry.time_modified = entry.modification
      
      for n,_ in pairs(Dir.values.string_els) do
         assert( type(entry[n]) == "string", 
                 string.format("%s not string, but %s", n, entry[n]))
      end
      for n,_ in pairs(Dir.values.int_els) do
         assert( type(entry[n]) == "number" or n == "id", 
                 string.format("%s not integer, but %s", n, entry[n]))
      end

      ret:update_or_enter(entry)
   end
   return ret
end
