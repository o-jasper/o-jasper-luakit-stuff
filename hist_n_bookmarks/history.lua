--  Copyright (C) 27-03-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "o_jasper_common"
local sql_help_meta = require("sql_help").sql_help_meta
require "listview.sql_entry"

require "listview.log"
require "listview.log_html"  -- TODO... Want this later.

local capi = { luakit = luakit, sqlite3 = sqlite3 }

-- History stuff.
history_entry_meta = copy_table(msg_meta)

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

history_meta.direct._msg = log_meta.direct._msg  -- TODO this is suckage.
history_meta.direct.exec = log_meta.direct.exec

function history_meta.direct.history_entry(self) return function(history_entry)
      history_entry.logger = self
      return setmetatable(history_entry, metatable_of(history_entry_meta))
end end

history_meta.direct.fun = history_meta.direct.history_entry
history_meta.values = history_entry_meta.values

local existing_history = require("history")
local db = existing_history.db
print("****", existing_history, db)
for k,v in pairs(existing_history._M) do print(k,v) end

history = setmetatable({ db = db }, metatable_of(history_meta))
