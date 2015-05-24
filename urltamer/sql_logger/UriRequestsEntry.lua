local c = require "o_jasper_common"

local UriRequestsEntry = c.copy_meta(require("sql_help").SqlEntry)

UriRequestsEntry.values = {  -- Note: it is overkill, shared with history_meta.vlaues.
   table_name = "uri_requests",

   idname = "id",
   row_names = {"id", "time", "uri", "vuri", "domain", "from_domain", "result"},

   time = "time", timemul = 1,
   order_by = "time",
   textlike = {"uri", "vuri"},

   string_els = c.values_now_set({"uri", "vuri", "domain", "from_domain"}),
   int_els = c.values_now_set({"id", "time"}),
}

return c.metatable_of(UriRequestsEntry)
