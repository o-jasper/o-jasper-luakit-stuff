local c = require "o_jasper_common"

local This = c.copy_meta(require("sql_help").SqlEntry)

This.values = {
   table_name = "moz_cookies",

   idname = "id",
   row_names = {"id", "name", "value", "host", "path", "expiry",
                "lastAccessed", "isSecure", "isHttpOnly"},

   time = "lastAccessed", timemul = 0.001,
   order_by = "lastAccessed",
   textlike = {"name", "value", "host", "path"},

   string_els = c.values_now_set({"name", "value", "host", "path"}),
   int_els = c.values_now_set({"id", "expiry", "lastAccessed", "isSecure", "isHttpOnly"}),
}

return c.metatable_of(This)
