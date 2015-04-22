
local SqlEntry = require("sql_help").SqlEntry

local c = require "o_jasper_common"

local HistoryEntry = c.copy_table(SqlEntry)

HistoryEntry.values = {  -- Note: it is overkill, shared with history_meta.vlaues.
   table_name = "history",
--   taggings = "history_implied",
--   tagfinder=[[SELECT tag FROM history_implied WHERE to_id == ?]],
   time = "last_visit", timemul = 1000,
   row_names = {"id", "uri", "title", "last_visit", "visits"},
   order_by = "last_visit",
   time_overkill = false,

   textlike = {"uri", "title"},
   string_els = c.values_now_set({"uri", "title"}),
   int_els = c.values_now_set({"id", "last_visit", "visits"}),
}

return c.metatable_of(HistoryEntry)
