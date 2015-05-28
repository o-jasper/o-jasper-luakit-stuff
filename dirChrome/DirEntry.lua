local c = require "o_jasper_common"

local DirEntry = c.copy_meta(require("sql_help").SqlEntry)

DirEntry.values = {
   table_name = "files",

   idname = "id",
   row_names = {"id", "dirname", "filename", "mode",
                "size", "time_access", "time_modified"},

   time = "time_modified", timemul = 1000,
   order_by = "time_modified",
   textlike = {"dirname", "filename"},

   string_els = c.values_now_set({"dirname", "filename", "mode"}),
   int_els = c.values_now_set({"id", "size", "time_access", "time_modified"}),
}

return c.metatable_of(DirEntry)
