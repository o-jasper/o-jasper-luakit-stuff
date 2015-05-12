local c = require "o_jasper_common"
local sql_help = require "sql_help"

local mod_BookmarksEntry = {
   values = {
      table_name = "bookmarks",
      taggings = "bookmark_taggings", tagname="tag",
      
      idname = "id",
      row_names = {"id", "created", "to_uri", "title", "desc", "data_uri"},
      
      time = "created", timemul=1000,
      order_by = "created",
      textlike = {"to_uri", "title", "desc"},
      
      string_els = {"to_uri", "title", "desc", "data_uri"},
      int_els = {"id", "created"},
   },
}

local BookmarksEntry = c.copy_meta(sql_help.SqlEntry, mod_BookmarksEntry)

return c.metatable_of(BookmarksEntry)
