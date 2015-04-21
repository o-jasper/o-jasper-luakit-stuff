--  Copyright (C) 14-03-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "o_jasper_common"
local sql_help = require("sql_help")
local sql_help_meta, sql_entry_meta = sql_help.sql_help_meta, sql_help.sql_entry_meta

require "listview.log_input_sanity"

local capi = { luakit = luakit, sqlite3 = sqlite3 }

msg_meta = copy_table(sql_entry_meta)

msg_meta.values = {
   table_name = "msgs",
   taggings = "taggings", tagname ="tag",
   tagfinder=[[SELECT tag FROM taggings WHERE to_id == ?]],
   order_by = "id",
   time = "id", timemul=0.001,
   row_names = {"id", "claimtime", "re_assess_time", "kind", "origin",
                "data", "data_uri",
                "uri", "title", "desc"
   },
   time_overkill = false,

   textlike = {"title", "uri", "desc"},
   string_els=values_now_set(string_els),
   int_els=values_now_set(int_els)
}

-- Logs entries have, likely meta-indexes,

log_meta = copy_table(sql_help_meta)

log_meta.values = msg_meta.values

-- Enter a message.
function log_meta.direct.db_enter(self) return function(msg)
      if msg.id then return "you dont get to set `id`(time), only `claimtime`" end
      msg.id = self:new_time_id()
      local sanity = log_input_sanity(msg)
      if sanity ~= "good" then return sanity end
      
      --if self.msg_re_assess then self:msg_re_assess(msg) end
      
      return sql_help_meta.direct.db_enter(self)(msg)
end end

function log_meta.direct.msg(self) return function (msg)
      if isinteger(msg) then
         return self:_msg(self.db:exec([[SELECT * WHERE id == ?]], msg))
      end
      return self:_msg(msg)
end end

function log_meta.direct._msg(self) return function (msg)
      msg.logger = self
      setmetatable(msg, metatable_of(msg_meta))
      return msg
end end

msg_meta.direct.fun = msg_meta.direct._msg

function log_meta.direct.exec(self) return function (sql)
      return map(self.db:exec(sql), function(msg) self:fun(msg) end)
end end

local function mk_db(path)
   local db = capi.sqlite3{ filename = path }
   db:exec [[
        PRAGMA synchronous = OFF;
        PRAGMA secure_delete = 1;

        CREATE TABLE IF NOT EXISTS msgs (
            id INTEGER PRIMARY KEY,
            claimtime INTEGER,
            re_assess_time INTEGER,

            kind TEXT NOT NULL,
            origin TEXT NOT NULL,

            data TEXT,
            data_uri TEXT,

            uri TEXT,
            title TEXT NOT NULL,
            desc TEXT
        );

        CREATE TABLE IF NOT EXISTS taggings (
            to_id INTEGER NOT NULL,
            tag TEXT NOT NULL
        );
    ]]
   return db
end

function new_log(path)
   local log = {db = mk_db(path),
                re_assess={list={}, forward=30, min_wait=60}
               }
   setmetatable(log, metatable_of(log_meta))
   return log
end
