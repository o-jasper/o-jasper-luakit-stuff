local c = require "o_jasper_common"
local sql_help = require "sql_help"

local this = c.copy_meta(sql_help.SqlEntry)
this.values = {
   table_name = "bookmarks",
   taggings = "bookmark_taggings", tagname="tag",
   
   idname = "id",
   row_names = {"id", "created", "to_uri", "title", "desc", "data_uri"},
   
   time = "created", timemul=1000,
   order_by = "created",
   textlike = {"to_uri", "title", "desc"},
   
   string_els = {"to_uri", "title", "desc", "data_uri"},
   int_els = {"id", "created"},
}

return c.metatable_of(this)
