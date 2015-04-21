--  Copyright (C) 27-03-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "o_jasper_common"

local sql_help = require("sql_help")
local sql_help_meta, sql_entry_meta = sql_help.sql_help_meta, sql_help.sql_entry_meta
require "listview.entry_html"  -- TODO... Want this later.

local capi = { luakit = luakit, sqlite3 = sqlite3 }

-- History stuff.
history_entry_meta = copy_table(sql_entry_meta)

history_entry_meta.values = {  -- Note: it is overkill, shared with history_meta.vlaues.
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

history_meta = copy_table(sql_help_meta)
history_meta.values = history_entry_meta.values

function history_meta:history_entry(entry)
   entry.origin = notself
   return setmetatable(history_entry, metatable_of(history_entry_meta))
end
--history_meta.produce_entry = history_meta.history_entry

history_meta.values = history_entry_meta.values

local existing_history = require("history")
local db = existing_history.db

history = setmetatable({ db = db }, metatable_of(history_meta))

sql_entry_meta.__index.values = history_entry_meta.values

assert(history_meta.__index.new_sql_help)
assert(history_meta.__index.produce_entry)
