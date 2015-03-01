--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "listview.common"
require "listview.sql_help"
require "listview.sanity"

local capi = { luakit = luakit, sqlite3 = sqlite3 }

-- Makes a metatable..
msg_meta = metatable_for({
   determine = {
      tags = function(self) return self.realtime_tags() end,
   },
   direct = {
      
   realtime_tags = function(self) return function()
         if self.logger.tags_last < self.tags_last then
               return self.tags
         end
         -- Get the tags.
         self.tags_last = cur_time()
         self.tags = {}
         local got = self.logger.db:exec([[SELECT tag FROM taggings WHERE to_id == ?]], 
                                         {self.id})
         for _, el in pairs(got) do
            table.insert(self.tags, el.tag)
         end
         return self.tags
   end end,
   }
})

for _, el in pairs(string_els) do  -- nil when supposed to be string reset to "".
   msg_meta.determine[el] = function(self) self[el] = "" end
end
for _, el in pairs(int_els) do  -- nil ...  int ... to `0`.
   msg_meta.determine[el] = function(self) self[el] = 0 end
end
msg_meta.direct.rt_tags = msg_meta.direct.realtime_tags

-- Logs entries have, likely meta-indexes,

local log_meta = metatable_for({
direct = {
   -- Those helps are intended to be separate objects!
   new_sql_help = function(self) return function(initial)
         return new_sql_help(nil, initial, self.db, self._msg)
   end end,

   -- Enter a message.
   enter = function(self) return function(origin, msg)
         -- NOTE: origin doesnt do anything at this point. It may be attempted
         -- to try separate different lua scripts.
         if msg.id then return "you dont get to set `id`(time), only `claimtime`" end
         msg.id = new_time_id()
         local sanity = msg_sanity(msg)
         if sanity ~= "good" then return sanity end
         
         --if self.msg_re_assess then self.msg_re_assess(msg) end
         
         ret = {}
         if msg.keep then  -- Only bother getting it if it is keepworthy.
            ret.msgs = self.db:exec(
               [[INSERT INTO msgs VALUES (?, ?, ?,  ?, ?,  ?, ?,  ?, ?, ?);]],
               { msg.id, msg.claimtime, msg.re_assess_time,
                 msg.kind, msg.origin,
                 msg.data, msg.data_uri,
                 msg.uri, msg.title, msg.desc
               })
            ret.tags = {}
            -- And all the tags.
            if msg.tags and #msg.tags > 0 then
               self.tags_last = cur_time()  -- Note time last changed.
               for _, tag in pairs(msg.tags) do
                  table.insert(ret.tags,
                               self.db:exec([[INSERT INTO taggings VALUES (?, ?);]],
                                            {msg.id, tag}))
               end
            end
         end
         return ret
   end end,

   delete = function(self) return function (id)
         self.db:exec([[DELETE FROM msgs WHERE id == ?;
                        DELETE FROM taggings WHERE to_id == ?;]], id, id)
   end end,

   update_entirely_by = function(self) return function(msg)
         self.db:exec([[UPDATE msgs SET
claimtime=?, re_assess_time=?,
kind=?, origin=?, data=?, data_uri=?,
uri=?, title=?, desc=?, tags=?
WHERE id == ?;]], {msg.claimtime, msg.re_assess_time,
                   msg.kind, msg.origin, msg.data, msg.data_uri,
                   msg.uri, msg.title, msg.desc, 
                   msg.id})
   end end,

   msg = function(self) return function (msg)
         if isinteger(msg) then
            return self._msg(self.db:exec([[SELECT * WHERE id == ?]], msg))
         end
         return self._msg(msg)
   end end,
   
   _msg = function(self) return function (msg)
         msg.logger = self
         msg.tags_last = 0
         setmetatable(msg, msg_meta.table)
         return msg
   end end,
}})

local function mk_db(path)
   local db = capi.sqlite3{ filename = path }
   db:exec [[
        PRAGMA synchronous = OFF;
        PRAGMA secure_delete = 1;

        CREATE TABLE IF NOT EXISTS msgs (
            id INTEGER PRIMARY KEY,
            claimtime INTEGER NOT NULL,
            re_assess_time INTEGER NOT NULL,

            kind TEXT NOT NULL,
            origin TEXT NOT NULL,

            data TEXT NOT NULL,
            data_uri TEXT NOT NULL,

            uri TEXT NOT NULL,
            title TEXT NOT NULL,
            desc TEXT NOT NULL
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
                tags_last = 0,
                re_assess={list={}, forward=30, min_wait=60}
               }
   setmetatable(log, log_meta.table)
   return log
end

local time_overkill, last_time = false, 0
function new_time_id()
   local time = cur_time_ms()*1000
   if time == last_time then time = time + 1 end
   -- Search for matching.
   while time_overkill and #db:exec([[SELECT id FROM msgs WHERE id == ?]], {time}) > 0 do
      time = time + 1
   end
   last_time = time
   return time
end

