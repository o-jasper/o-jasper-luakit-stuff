require "listview.common"
require "listview.sql_help"
require "listview.sql_entry"

history_entry_meta = copy_table(sqlentry_meta)

history_entry_meta.values = {  -- Note: it is overkill, shared with history_meta.vlaues.
   table_name = "history",
   taggings = "history_implied",  -- Not really tags.. acts the same though.
   tagfinder=[[SELECT tag FROM history_implied WHERE to_id == ?]],
   time = "id",
   row_names = {"id", "last_time", "visits", "uri", "title"},
   time_overkill = false,

   textlike = {"uri", "title"},
   string_els = values_now_set("uri", "title"),
   int_els = values_now_set({"id", "last_time", "visits"}),
}

history_meta = copy_table(sql_meta)
history_meta.values = history_entry_meta.values

-- Enter a message.
function history_meta.direct.db_enter(self) return function(msg)
      if msg.id then return "you dont get to set `id`(time) of history, i do that.`" end
      hist_entry.id = self.new_time_id()
      return sql_help_meta.direct.hist_entry_id(self)(hist_entry)
end end

function history_meta.direct.history_entry(self) return function(history_entry)
      history_entry.logger = self
      setmetatable(msg, metatable_of(msg_meta))
      return history_entry
end end

history_meta.direct.fun = history_meta.direct.history_entry

local function mk_db(path)
   local db = capi.sqlite3{ filename = path }
   db:exec [[
        PRAGMA synchronous = OFF;
        PRAGMA secure_delete = 1;

        CREATE TABLE IF NOT EXISTS history (
            id INTEGER PRIMARY KEY,
            last_time INTEGER,
            visits INTEGER,

            uri TEXT NOT NULL,
            title TEXT NOT NULL,
        );

        CREATE TABLE IF NOT EXISTS history_implied (
            to_id INTEGER NOT NULL,
            tag TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS bookmarks (
            id INTEGER PRIMARY KEY,

            uri TEXT NOT NULL,
            title TEXT NOT NULL,
            desc TEXT NOT NULL,

            data_uri TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS taggings (
            to_id INTEGER NOT NULL,
            tag TEXT NOT NULL
        );
    ]]
   return db
end

function new_history(path)
   local history = { db = mk_db(path or config.dbfile or "grand.db") }
   setmetatable(history, metatable_of(history_meta))
   return history
end
