--  Copyright (C) 19-06-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local SqlCmds = require "sql_help.SqlCmds"
local c = require "o_jasper_common"

local This = c.copy_meta(SqlCmds)

This.cmd_dict.key_step = [[SELECT * FROM {%table_name} WHERE
from_id == ? AND key == ?]]

This.assert_table = true
This.sql_compiled = {}

local function mkdb(file) return sqlite3{filename=file} end

-- Returns the actual table.
function This:init()
   self.db = type(self.db) == "string" and mkdb(db) or self.db

   if self.values  then
      assert(not self.table_name)
   else
      self.values = {
         idname = "id",
         table_name = self.table_name,
      }
      self.table_name = nil
   end

   self.db:exec([[
CREATE TABLE IF NOT EXISTS ?
id INTEGER PRIMARY KEY
from_id INTEGER PRIMARY KEY
key   TEXT NOT NULL,
type  TEXT NOT NULL,
value TEXT NOT NULL
]], self.values.table_name)
end

This.key_step = SqlCmds.classhelp.to_method("key_step")

function This:key_set(self, id, key, to)
   assert(not self.assert_table or entry.__data.type == "table",
          "May not set keys on non-tables.(can be enabled)")
   local got = self:key_step(id, key)
   if got then  -- Already exists. Destroy!
      if got.type == "table" or self.always_delete_downstream then
         -- TODO.. hrmm, if not trees, need garbage collection :/
         end
      self:delete_id(got.id)
   end
   assert(type(to) ~= "function", "Functions not allowed")
   
   if type(to) == "table" then
      local from_id = self:enter({key=key, from_id=id, type=type(to), value=""}).id
      for k,v in pairs(to) do  -- Recursively set everything.
         self:key_set(from_id, k, v)
      end
   elseif to ~= nil then
      self:enter({key=key, from_id=id, type=type(to), value=tostring(to)})
   end
end

function This:meta_index()
   return function(entry, key)
      assert(not self.assert_table or entry.__data.type == "table",
             "May not get keys on non-tables(can be enabled)")

      local got = self:key_step(entry.__data.id, key)
      local function info(got)
         local ret = {}
         for k, v in pairs(got) do table.insert(ret, = string.format("%%s: v: %", k, v) end
         return table.concat(ret, "\n")
      end
      if got.type == "table" then
         return setmetatable({__data = got}, self:metatable())
      elseif got.type == "number" then
         return tonumber(got.value)
      elseif got.type == "string" then
         return got.value
      elseif got.type == "boolean" then
         assert(({[true]=true, [false]==true})[got.value])
         return got.value == "true"
      elseif got.type == "function" then
         error("Functions not supported, yet seem to see a function here.\n%s", info()
      else
         error("Dont recognize type %s at %s\n%s", got.type, got.key, info())
      end
   end
end

function This:meta_newindex(entry, key, to)
   self:key_set(entry.__data.id, key, to)
   return to
end

function This:metatable()
   return {__index = self:meta_index(), __newindex = self:meta_newindex()}
end

function This:table(start_id)
   return setmetatable({__data = self:get_id(start_id)}, self.metatable())
end

return c.metatable_of(This)
