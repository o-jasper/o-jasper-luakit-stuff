--  Copyright (C) 27-03-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local OldBookmarks = require "listview.history.OldBookmarks"

local bookmarks = require("bookmarks")
bookmarks.init()

local ret
if not ret then
   ret = setmetatable({ db = bookmarks.db }, OldBookmarks)
end

return ret
