local c = require "o_jasper_common"

local UriRequestsEntry = c.copy_meta(require("sql_help").SqlEntry)

UriRequestsEntry.values = {  -- Note: it is overkill, shared with history_meta.vlaues.
   table_name = "uri_requests",
--   taggings = "history_implied", -- (possibly record what outside stuff is loaded)
--   tagfinder=[[SELECT tag FROM history_implied WHERE to_id == ?]],
   idname = "id",
   row_names = {"id", "time", "uri", "vuri", "domain", "from_domain", "result"},

   time = "time", timemul = 1000,
   order_by = "time",
   textlike = {"uri", "vuri"},

   string_els = c.values_now_set({"uri", "vuri", "domain", "from_domain"}),
   int_els = c.values_now_set({"id", "time"}),
}

return c.metatable_of(UriRequestsEntry)
