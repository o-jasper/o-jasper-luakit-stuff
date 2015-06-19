--  Copyright (C) 19-06-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local function qmarks(n)  -- Makes a string with a number of question marks in it.
   if n == 0 then return "" end
   local str = "?"
   while n > 1 do
      str = str .. ", ?"
      n = n - 1
   end
   return str
end

local This = {
   cmd_dict = {  -- TODO make these automatically function-able.
      selectid = "SELECT {%idname} FROM {%table_name} WHERE {%idname} == ?",
      get_id   = "SELECT * FROM {%table_name} WHERE {%idname} == ?",
      delete_entry_id = "DELETE FROM {%table_name} WHERE {%idname} == ?",

      enter = function(self)
         return string.format("INSERT INTO %s VALUES (%s)",
                              self.values.table_name, qmarks(#self.values.row_names))
      end,
      update = function(self)  -- Unused, just delete-and-re-add.
         local changer = {}
         for _, v in pairs(self.values.row_names) do
            table.insert(changer, v .. " = ?")
         end
         return string.format("UPDATE %s SET %s WHERE %s == ?",
                              self.values.table_name,
                              table.concat(changer, ", "),
                              self.values.idname)
      end,
   },
   sql_compiled = {}
}

-- Intended as replacable ("virtual") or just change self.entry_meta
function This:entry_fun(self, data)
   assert(type(data) == "table")
   data.origin = self
   setmetatable(data, self.entry_meta)  -- self.entry_meta == nil is fine.
   return data
end
function This:list_fun(self, list)
   for _, data in pairs(list) do
      self:entry_fun(data)
   end
   return list
end

This.classhelp = {
   sqlcmd_to_method = function(Into, name, is_entries)
      if is_entries then
         Into[name] = function(self, ...)
            return self:entry_fun((self:sql_cmd(name):exec{...} or {})[1])
         end
         Into["list_" .. name] = function(self, ...)
            return self:list_fun(self:sql_cmd(name):exec{...} or {})
         end
      else
         Into[name] = function(self, ...)
            return (self:sql_cmd(name):exec{...} or {})[1]
         end
         Into["list_" .. name] = function(self, ...)
            return self:sql_cmd(name):exec{...} or {}
         end         
      end
   end,
}

-- Gets/makes a command,
-- Compiles into the metatable. That assumes the same `self.db`, 
-- and consistent `cmd_dicts`.
function This:sqlcmd(what)
   local got = self.sql_compiled[what]
   if not got then
      local maybefun = self.cmd_dict[what]
      if type(maybefun) == "string" then
         got = string.gsub(maybefun, "{%%([_./%w]+)}", self.values)
      else
         got = maybefun(self)
      end
      got = self.db:compile(got)
      -- *If* `sql_compiled` not set, actually sets the metatable.
      self.sql_compiled[what] = got
   end
   return got
end

local cur_time = require "o_jasper_common.cur_time"

-- Add an entry.
function This:enter(entry)
   assert(self.values.table_name and self.values.row_names)
   
   if not entry.id then
      self.cur_id = 1000*cur_time.ms()
      local got = self:get_id(self.cur_id)
      while got do
         self.cur_id = self.cur_id + 1
         got = self:get_id(self.cur_id)
      end
      entry.id = self.cur_id
   end
   
   return { add = self:sqlcmd("enter"):exec(self:args_in_order(entry)) }
end
-- Modify an entry.
function This:update(entry)
   if not entry.id then return nil end
   local got = self:sqlcmd("selectid"):exec({entry.id})
   if #got == 1 then  -- It must exist, otherwise it isnt an update.
      return self:force_update(entry) or self:get_id(entry.id) or true
   end
end
function This:update_or_enter(entry)
   local got = self:update(entry)
   if got then
      return got
   else
      return self:enter(entry)
   end
end

function This:force_update(entry)
   assert(entry.id)
   self:delete_id(entry.id)  -- Delete previous
   return self:enter(entry)
   --      local inp = self:args_in_order(entry) -- Does it matter?
   --      table.insert(inp, entry.id)
   --      return self:sqlcmd("update"):exec(inp)
end

-- Delete an entry.
function This:delete_id(id)
   self:sqlcmd("delete_entry_id"):exec({id})
   
   if self.values.taggings then
      self:sqlcmd("delete_tags_id"):exec({id})
   end
end

function This:get_id(id)
   local got = self:sqlcmd("get_id"):exec({id})[1]
   if got then
      return self:entry_fun(got)
   end
end

local c = require "o_jasper_common"

return c.metatable_of(This)
