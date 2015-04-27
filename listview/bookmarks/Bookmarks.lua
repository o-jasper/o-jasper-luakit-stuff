
local c = require "o_jasper_common"

local SqlHelp = require("sql_help").SqlHelp
local Bookmarks = c.copy_meta(SqlHelp)

local BookmarksEntry = require "listview.bookmarks.BookmarksEntry"
Bookmarks.values = BookmarksEntry.values

-- Bookmarks.searchinfo.matchable -- All of them.
-- TODO add data_uri: stuff.

local addfuns = {
   bookmark_entry = function(self, entry)
      entry.origin = self
      return setmetatable(entry, BookmarkEntry)
   end,
   
   listfun = function(self, list)
      for _, data in pairs(list) do
         data.orign = self
         setmetatable(data, BookmarkEntry)
      end
      return list
   end,

   enter = function(self, add)
      add.id = "NULL"  -- Then it should generate an id for us.
      -- Pass on the rest of the responsibility upstream.
      return SqlHelp.enter(self, add)
   end,
}

for k,v in pairs(addfuns) do Bookmarks[k] = v end

return c.metatable_of(Bookmarks)
