local c = require "o_jasper_common"

local This = c.copy_meta(require("sql_help").SqlEntry)

This.values = {
   table_name = "contacts",
--   taggings = "history_implied", -- (possibly record what outside stuff is loaded)
--   tagfinder=[[SELECT tag FROM history_implied WHERE to_id == ?]],
   idname = "id",
   row_names = {"id", "key", "note", "alias", "isblocked", "ingroup"},

--   time = "last_visit", timemul = 1000,
--   order_by = "id",
   textlike = {"key", "note", "alias", "ingroup"},

   string_els = c.values_now_set({"key", "note", "alias", "ingroup"}),
   int_els = c.values_now_set({"id", "isblocked"}),
}

return c.metatable_of(This)
