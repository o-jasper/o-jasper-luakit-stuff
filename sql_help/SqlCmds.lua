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
   cmd_dict = {
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

      -- Tag stuff, less likely to apply for the user, but here anyway.
      just_tags = "SELECT tag FROM {%taggings} WHERE to_id == ?",
      has_tag   = "SELECT tag FROM {%taggings} WHERE to_id == ? AND {%tagname} == ?",

      tags_insert     = "INSERT INTO {%taggings} VALUES (?, ?);",
      delete_tags_id  = "DELETE FROM {%taggings} WHERE to_{%idname} == ?",
   },
   sql_compiled = {}
}
   
function This:sqlcmd(what)
   local got = self.sql_compiled[what]
   if got then return got end
   local maybefun = self.cmd_dict[what]
   if type(maybefun) == "string" then
      got = string.gsub(maybefun, "{%%([_./%w]+)}", self.values)
   else
      got = maybefun(self)
   end
   got = self.db:compile(got)
      getmetatable(self).__index.sql_compiled[what] = got
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
   
   local ret = { add = self:sqlcmd("enter"):exec(self:args_in_order(entry)) }
   -- And all the tags, if we do those.
   if entry.tags and #entry.tags > 0 and self.values.taggings then
      self.tags_last = cur_time.raw()  -- Note time last changed.
      local tags_insert = self:sqlcmd("tags_insert")
      ret.tags = {}
      for _, tag in pairs(entry.tags) do
         table.insert(ret.tags, tags_insert:exec({entry[self.values.idname], tag}))
      end
   end
   return ret
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

function This:just_tags(id)
   -- Get the tags.
   local tags = {}
   for _, el in pairs(self:sqlcmd("just_tags"):exec({id})) do
      table.insert(tags, el.tag)
   end
   return tags      
end

function This:has_tag(id, tagname)
   local got = self:sqlcmd("has_tag"):exec({id, tagname})
   assert(not got or #got < 2)  -- Otherwise.. i dunno.
   return #got == 1
end

local c = require("o_jasper_common")

return c.metatable_of(This)
