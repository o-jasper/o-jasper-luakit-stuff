local c = require "o_jasper_common"

local This = c.copy_meta(require("sql_help").SqlEntry)

This.values = {
   table_name = "history",
--   taggings = "history_implied", -- (possibly record what outside stuff is loaded)
--   tagfinder=[[SELECT tag FROM history_implied WHERE to_id == ?]],
   idname = "id",
   row_names = {"id", "userHash", "contactHash", "message", "timestamp", "issent"},

   time = "timestamp", timemul = 1000,
   order_by = "timestamp",
   textlike = {"message"},

   string_els = c.values_now_set({"userHash", "contactHash", "message"}),
   int_els = c.values_now_set({"id", "timestamp", "issent"}),
}

return c.metatable_of(This)
