local c = require "o_jasper_common"

local this = c.copy_meta(require("sql_help").SqlEntry)

this.values = {
   table_name = "bookmarks",

   idname = "id",
   row_names = {"id", "uri", "title", "desc", "tags", "created", "modified"},

   time = "modified", timemul = 1000,
   order_by = "modified",
   textlike = {"uri", "title", "desc", "tags"},

   string_els = c.values_now_set({"uri", "title", "desc", "tags"}),
   int_els = c.values_now_set({"id", "created", "modified"}),
}

return c.metatable_of(this)
