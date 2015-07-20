--  Copyright (C) 27-03-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local OldBookmarks = require "listview.oldBookmarks.OldBookmarks"

local db

if luakit then
   local bookmarks = require("bookmarks")
   bookmarks.init()
   db = bookmarks.db
else
   local Sql = require "sql_help.luasql_port"
   db = Sql.new(globals.main_db_dir .. "bookmarks.db")
end

local ret
if not ret then
   ret = setmetatable({ db = db }, OldBookmarks)
end

return ret
