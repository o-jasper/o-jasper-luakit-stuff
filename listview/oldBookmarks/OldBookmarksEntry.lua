local c = require "o_jasper_common"

local OldBookmarksEntry = c.copy_meta(require("sql_help").SqlEntry)

OldBookmarksEntry.values = {  -- Note: it is overkill, shared with history_meta.vlaues.
   table_name = "history",
--   taggings = "history_implied", -- (possibly record what outside stuff is loaded)
--   tagfinder=[[SELECT tag FROM history_implied WHERE to_id == ?]],
   idname = "id",
   row_names = {"id", "uri", "title", "desc", "tags", "created", "modified"},

   time = "modified", timemul = 1000,
   order_by = "modified",
   textlike = {"uri", "title", "desc", "tags"},

   string_els = c.values_now_set({"uri", "title", "desc", "tags"}),
   int_els = c.values_now_set({"id", "created", "modified"}),
}

return c.metatable_of(OldBookmarksEntry)
