local c = require "o_jasper_common"

local HistoryEntry = c.copy_meta(require("sql_help").SqlEntry)

HistoryEntry.values = {  -- Note: it is overkill, shared with history_meta.vlaues.
   table_name = "history",
--   taggings = "history_implied", -- (possibly record what outside stuff is loaded)
--   tagfinder=[[SELECT tag FROM history_implied WHERE to_id == ?]],
   idname = "id",
   row_names = {"id", "uri", "title", "last_visit", "visits"},

   time = "last_visit", timemul = 1000,
   order_by = "last_visit",
   textlike = {"uri", "title"},

   string_els = c.values_now_set({"uri", "title"}),
   int_els = c.values_now_set({"id", "last_visit", "visits"}),
}

return c.metatable_of(HistoryEntry)
