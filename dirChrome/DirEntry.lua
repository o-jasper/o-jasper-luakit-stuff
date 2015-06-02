local c = require "o_jasper_common"

this = c.copy_meta(require("sql_help").SqlEntry)

this.values = {
   table_name = "files",
   
   idname = "id",
   row_names = {"id", "dir", "file", "mode",
                "size", "time_access", "time_modified"},
   
   time = "time_modified", timemul = 1000,
   order_by = "time_modified",
   textlike = {"dir", "file"},
   
   string_els = c.values_now_set({"dir", "file", "mode"}),
   int_els = c.values_now_set({"id", "size", "time_access", "time_modified"}),
}

return c.metatable_of(this)
