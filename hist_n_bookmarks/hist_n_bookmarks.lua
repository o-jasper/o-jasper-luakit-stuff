--  Copyright (C) 27-03-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "o_jasper_common"
require "listview.sql_help"
require "listview.sql_entry"

local capi = { luakit = luakit, sqlite3 = sqlite3 }

-- History stuff.
history_entry_meta = copy_table(sqlentry_meta)

history_entry_meta.values = {  -- Note: it is overkill, shared with history_meta.vlaues.
   table_name = "history",
--   taggings = "history_implied",
--   tagfinder=[[SELECT tag FROM history_implied WHERE to_id == ?]],
   time = "last_time",
   row_names = {"uri", "title", "last_time", "visits"},
   time_overkill = false,

   textlike = {"uri", "title"},
   string_els = values_now_set({"uri", "title"}),
   int_els = values_now_set({"id", "last_time", "visits"}),
}

history_meta = copy_table(sql_help_meta)
history_meta.values = history_entry_meta.values

-- Enter a message.
function history_meta.direct.db_enter(self) return function(add)
      local ret = {}
      -- Whether implied not yet implemented.
      local sql = string.format("INSERT INTO %s VALUES (%s)",
                                self.values.table_name, qmarks(#self.values.row_names))
      ret.add = self.db:exec(sql, self.args_in_order(add))
      return ret
end end

function history_meta.direct.see(self) return function(entry)
      local got = self.db:exec("SELECT * FROM history WHERE uri == ?", {entry.uri})
      if #got == 0 then
         return self.db_enter(self.history_entry(entry))
      else
         assert(#got == 1)
         self.db:exec("DELETE FROM history WHERE uri == ?", {entry.uri})
         entry.visits = (got.visits or 0) + 1
         return self.db_enter(self.history_entry(entry))
      end
end end

function history_meta.direct.history_entry(self) return function(history_entry)
      history_entry.logger = self
      return setmetatable(history_entry, metatable_of(history_entry_meta))
end end

history_meta.direct.fun = history_meta.direct.history_entry
history_meta.values = history_entry_meta.values

-- Bookmark stuff.
bookmarks_entry_meta = copy_table(sqlentry_meta)

bookmarks_entry_meta.values = {
   table_name = "bookmarks",
   taggings = "taggings", tagname="tag",

   idname = "id", 
   time = "id", time_overkill = false,

   hist_row_names = {"id", "to_uri", "title", "desc", "data_uri"},
   textlike = {"to_uri", "title", "desc"},
   string_els = {"to_uri", "title", "desc", "data_uri"},
   int_els = {"id"},

   textlike = {"uri", "title"},
   string_els = values_now_set({"uri", "title"}),
   int_els = values_now_set({"id", "last_time", "visits"}),
}

bookmarks_meta = copy_table(sql_help_meta)
bookmarks_meta.values = bookmarks_entry_meta.values

-- Creation.
local config = globals.hist_n_bookmarks or {}

local db = nil
local function mk_db(path)
   if not db then
      path = path or config.dbfile or "grand.db"
      db = capi.sqlite3{ filename = path }
      db:exec [[
        PRAGMA synchronous = OFF;
        PRAGMA secure_delete = 1;

        CREATE TABLE IF NOT EXISTS history (
            uri TEXT PRIMARY KEY,
            title TEXT NOT NULL,

            last_time INTEGER,
            visits INTEGER
        );

        CREATE TABLE IF NOT EXISTS history_implied (
            to_uri TEXT PRIMARY KEY,
            uri TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS bookmarks (
            id INTEGER PRIMARY KEY,

            to_uri TEXT NOT NULL,
            title TEXT NOT NULL,
            desc TEXT NOT NULL,

            data_uri TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS taggings (
            to_id INTEGER NOT NULL,
            tag TEXT NOT NULL
        );
    ]]
   end
   return db
end
history   = setmetatable({ db = mk_db() }, metatable_of(history_meta))
bookmarks = setmetatable({ db = mk_db() }, metatable_of(bookmarks_meta))
