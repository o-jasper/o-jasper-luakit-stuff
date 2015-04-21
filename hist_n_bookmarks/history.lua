--  Copyright (C) 27-03-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "o_jasper_common"

local sql_help = require("sql_help")
local SqlHelp, SqlEntry = sql_help.SqlHelp, sql_help.SqlEntry
require "listview.entry_html"  -- TODO... Want this later.

local capi = { luakit = luakit, sqlite3 = sqlite3 }

-- History stuff.
HistoryEntry = copy_table(SqlEntry)

HistoryEntry.values = {  -- Note: it is overkill, shared with history_meta.vlaues.
   table_name = "history",
--   taggings = "history_implied",
--   tagfinder=[[SELECT tag FROM history_implied WHERE to_id == ?]],
   time = "last_visit", timemul = 1000,
   row_names = {"id", "uri", "title", "last_visit", "visits"},
   order_by = "last_visit",
   time_overkill = false,

   textlike = {"uri", "title"},
   string_els = values_now_set({"uri", "title"}),
   int_els = values_now_set({"id", "last_visit", "visits"}),
}

History = copy_table(SqlHelp)
History.values = HistoryEntry.values

function History:history_entry(entry)
   entry.origin = self
   return setmetatable(history_entry, metatable_of(HistoryEntry))
end
--History.produce_entry = History.history_entry
History.values = HistoryEntry.values

local db = require("history").db
history = setmetatable({ db = db }, metatable_of(History))

SqlEntry.__index.values = HistoryEntry.values
SqlEntry.values = HistoryEntry.values

assert(History.__index.new_SqlHelp)
assert(History.__index.produce_entry)
